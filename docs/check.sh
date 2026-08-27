#!/usr/bin/env bash
#
# check.sh - structural checks over Rootloom's planning documents.
#
# Everything here is deterministic. The semantic question these cannot answer -
# whether an intent bullet in user-experience.md is actually covered by the
# requirements claiming to cover it - belongs to the coverage-audit skill.
#
# Usage:  docs/check.sh [-q]      -q prints only failures and the summary.
# Exit:   0 all checks passed, 1 one or more failed.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

QUIET=0
[ "${1:-}" = "-q" ] && QUIET=1

WRAP_MAX=100          # hard limit for prose in the hard-wrapped documents
WRAPPED="docs/data.md docs/taxonomy.md docs/user-interface.md docs/engineering.md docs/privacy.md docs/operating-model.md"

command -v python3 >/dev/null 2>&1 || { echo "check.sh needs python3"; exit 2; }

export QUIET WRAP_MAX WRAPPED

python3 <<'PY'
import os, re, sys, glob, collections

QUIET = os.environ["QUIET"] == "1"
WRAP_MAX = int(os.environ["WRAP_MAX"])
WRAPPED = os.environ["WRAPPED"].split()

DOCS = sorted(glob.glob("docs/*.md"))
ALL = ["CLAUDE.md", "README.md", "SECURITY.md"] + DOCS
AUTHORITATIVE = [d for d in DOCS if not d.endswith("notes.md")]

def read(p):
    try:
        return open(p, encoding="utf-8").read()
    except FileNotFoundError:
        return ""

failures = []

def check(name, problems, note=""):
    """problems: list of strings. Empty list == pass."""
    if problems:
        failures.append(name)
        print(f"FAIL  {name}  ({len(problems)})")
        for p in problems[:20]:
            print(f"        {p}")
        if len(problems) > 20:
            print(f"        ... and {len(problems)-20} more")
    elif not QUIET:
        print(f"ok    {name}{('  ' + note) if note else ''}")

# --- 1. relative links resolve ------------------------------------------------
problems = []
for f in ALL:
    for m in re.finditer(r'\]\(([^)\s#]+\.md)(#[^)]*)?\)', read(f)):
        target = m.group(1)
        base = os.path.dirname(f) or "."
        if not (os.path.isfile(os.path.join(base, target)) or os.path.isfile(target)):
            problems.append(f"{f}: {target}")
check("links", problems, "all relative .md links resolve")

# --- requirement inventory ----------------------------------------------------
req_src = read("docs/requirements.md")
req_lines = [(i + 1, l) for i, l in enumerate(req_src.splitlines())
             if re.match(r'^- \*\*(FR|NFR)-', l)]
defined, order = set(), []
for ln, l in req_lines:
    rid = re.match(r'^- \*\*((?:FR|NFR)-[A-Z0-9]+-\d+)\*\*', l).group(1)
    order.append((rid, ln, l))
    defined.add(rid)

# A retirement leaves a tombstone: `- ~~**NFR-DATA-08**~~ *Retired, superseded...`
# It is not a requirement - no marker, no phase, and citing it is an error - but
# it is what makes the gap it leaves in the sequence deliberate rather than lost.
retired = set(re.findall(r'^- ~~\*\*((?:FR|NFR)-[A-Z0-9]+-\d+)\*\*~~',
                         req_src, flags=re.M))

# --- 2. identifiers unique and sequential ------------------------------------
problems = []
seen = collections.Counter(r for r, _, _ in order)
problems += [f"duplicate {r} (x{n})" for r, n in seen.items() if n > 1]
by_area = collections.defaultdict(list)
for rid, ln, _ in order:
    area, num = rid.rsplit("-", 1)
    by_area[area].append((int(num), ln))
for area, nums in by_area.items():
    seq = [n for n, _ in nums]
    if seq != sorted(seq):
        problems.append(f"{area} is not in ascending order: {seq}")
    expected = list(range(1, len(seq) + 1))
    missing = sorted(set(expected) - set(seq))
    unaccounted = [n for n in missing if f"{area}-{n:02d}" not in retired]
    if unaccounted:
        problems.append(f"{area} has gaps at {unaccounted} with no retirement tombstone")
problems += [f"{r} is both retired and defined" for r in sorted(retired & defined)]
check("req-ids", problems,
      f"{len(defined)} requirements, {len(by_area)} areas, no duplicates, "
      f"{len(retired)} retired and every gap accounted for")

# --- 3. every requirement carries a verification marker -----------------------
MARKERS = {"test", "ci", "manual", "monitor", "policy"}
problems = []
for rid, ln, l in order:
    m = re.match(r'^- \*\*[A-Z0-9-]+\*\* `([a-z]+)`', l)
    if not m:
        problems.append(f"{rid} (line {ln}) has no verification marker")
    elif m.group(1) not in MARKERS:
        problems.append(f"{rid} (line {ln}) has unknown marker `{m.group(1)}`")
counts = collections.Counter(
    m.group(1) for _, _, l in order
    if (m := re.match(r'^- \*\*[A-Z0-9-]+\*\* `([a-z]+)`', l)))
check("req-markers", problems,
      " ".join(f"{k}:{v}" for k, v in sorted(counts.items())))

# --- 4. no phantom citations --------------------------------------------------
problems = []
for f in ["CLAUDE.md", "README.md"] + [d for d in AUTHORITATIVE
                                       if not d.endswith("requirements.md")]:
    for rid in sorted(set(re.findall(r'(?:FR|NFR)-[A-Z0-9]+-\d+', read(f)))):
        if rid in retired:
            problems.append(f"{f} cites retired {rid}")
        elif rid not in defined:
            problems.append(f"{f} cites undefined {rid}")
cited = set()
for f in AUTHORITATIVE + ["CLAUDE.md"]:
    if f.endswith("requirements.md"):
        continue
    cited |= set(re.findall(r'(?:FR|NFR)-[A-Z0-9]+-\d+', read(f)))
check("citations", problems, f"{len(cited & defined)} distinct IDs cited externally, all defined")

# --- 5. every requirement in exactly one roadmap phase ------------------------
road = read("docs/roadmap.md")
# Only `### P<n>` headings are phases, and a phase body ends at the next heading
# of either level - so identifiers cited in the prose sections that follow the
# last phase (What could move this, Beyond Release 2) are not attributed to it.
phase_bodies = re.findall(r'^### (P\d+[^\n]*)\n(.*?)(?=^### |^## |\Z)',
                          road, flags=re.M | re.S)
placed = collections.Counter()
where = collections.defaultdict(list)
for phase, text in phase_bodies:
    phase = phase.strip()
    ids_here = set()
    for a, b in re.findall(
            r'`((?:FR|NFR)-[A-Z0-9]+-\d+)`\s*[–—-]\s*`((?:FR|NFR)-[A-Z0-9]+-\d+)`', text):
        pa, na = a.rsplit("-", 1); pb, nb = b.rsplit("-", 1)
        if pa == pb:
            for n in range(int(na), int(nb) + 1):
                ids_here.add(f"{pa}-{n:02d}")
            text = text.replace(f"`{a}`", " ").replace(f"`{b}`", " ")
    ids_here |= set(re.findall(r'`((?:FR|NFR)-[A-Z0-9]+-\d+)`', text))
    for rid in ids_here:
        placed[rid] += 1
        where[rid].append(phase)
problems = []
problems += [f"unplaced {r}" for r in sorted(defined - set(placed))]
problems += [f"phantom {r} in roadmap" for r in sorted(set(placed) - defined)]
problems += [f"{r} appears in {len(where[r])} phases: {', '.join(where[r])}"
             for r in sorted(placed) if placed[r] > 1]
check("roadmap", problems, f"{len(defined & set(placed))}/{len(defined)} placed exactly once")

# --- 6. functional areas map to features -------------------------------------
ux = read("docs/user-experience.md")
area_map = dict(re.findall(r'^\| `([A-Z]+)` \| (.+?) \|$', req_src, flags=re.M))
ux_features = set(re.findall(r'^#### (.+)$', ux, flags=re.M))
req_sections = set(re.findall(r'^### (.+)$', req_src, flags=re.M))
problems = []
for area, feature in area_map.items():
    if feature not in req_sections:
        problems.append(f"`{area}` maps to \"{feature}\" - no such section in requirements.md")
    if area != "JRN" and feature not in ux_features:
        problems.append(f"`{area}` maps to \"{feature}\" - no such feature in user-experience.md")
for area in sorted({r.rsplit('-', 1)[0].split('-', 1)[1] for r in defined if r.startswith("FR-")}):
    if area not in area_map:
        problems.append(f"area `{area}` has requirements but no row in the mapping table")
check("areas", problems, f"{len(area_map)} areas map to features in both registers")

# --- 7. emphasis balance in italic feature descriptions ----------------------
# A nested *emphasis* inside a single-span italic paragraph terminates it early.
problems = []
for i, line in enumerate(ux.splitlines(), 1):
    if line.startswith("*") and line.endswith("*") and not line.startswith("**"):
        if line.count("*") != 2:
            problems.append(f"user-experience.md:{i} italic span contains "
                            f"{line.count('*') - 2} extra asterisk(s)")
check("emphasis", problems, "italic feature descriptions are single unbroken spans")

# --- 8. hard-wrap conformance -------------------------------------------------
problems = []
for f in WRAPPED:
    lines = read(f).splitlines()
    in_fence = in_front = False
    for i, line in enumerate(lines, 1):
        if i == 1 and line.strip() == "---":
            in_front = True; continue
        if in_front:
            if line.strip() == "---":
                in_front = False
            continue
        if line.lstrip().startswith("```"):
            in_fence = not in_fence; continue
        if in_fence or line.lstrip().startswith("|"):
            continue
        if len(line) > WRAP_MAX:
            problems.append(f"{f}:{i} is {len(line)} columns")
check("wrap", problems, f"prose in hard-wrapped docs stays under {WRAP_MAX} columns")

# --- 9. mermaid fences balanced ----------------------------------------------
problems = []
for f in AUTHORITATIVE:
    body = read(f)
    if body.count("```") % 2:
        problems.append(f"{f} has an odd number of code fences")
    for m in re.finditer(r'```mermaid\n(.*?)```', body, flags=re.S):
        block = m.group(1)
        if not re.match(r'\s*(erDiagram|flowchart|graph|sequenceDiagram|stateDiagram)', block):
            line = body[:m.start()].count("\n") + 1
            problems.append(f"{f}:{line} mermaid block has no recognised diagram type")
check("mermaid", problems, "code fences balanced, mermaid blocks declare a diagram type")

# --- 10. roadmap dates re-derive from the hours ------------------------------
# "Dates are derived, not chosen" - so they are checkable. Start, capacity, and
# the break are read from the inputs table rather than hardcoded here.
problems = []
try:
    from datetime import date, timedelta
    def _d(t):
        t = t.strip().replace("Sept", "Sep")
        for fmt in ("%d %B %Y", "%d %b %Y"):
            try:
                import datetime as _dt
                return _dt.datetime.strptime(t, fmt).date()
            except ValueError:
                pass
        return None
    start = _d(re.search(r'\| Start \| ([^|]+) \|', road).group(1))
    cap = float(re.search(r'\| Sustained capacity \| (\d+) hours', road).group(1))
    bk = re.search(r'\| Planned break \| ([^–|]+)[–-]([^|]+) \|', road)
    bs, be = _d(bk.group(1)), _d(bk.group(2))
    rows = re.findall(
        r'^\| (P\d+) · [^|]+\| (\d+) \| ([^|]+?) \| \*{0,2}([^|*]+?)\*{0,2} \|$',
        road, flags=re.M)
    cur = start
    for name, hours, stated_start, stated_end in rows:
        if _d(stated_start) != cur:
            problems.append(f"{name} starts {stated_start.strip()}, derived {cur:%-d %b %Y}")
        cur = cur + timedelta(days=int(hours) / cap * 7)
        if bs and bs <= cur and cur <= be + timedelta(days=int(hours) / cap * 7):
            if stated_start and _d(stated_start) < bs <= cur:
                cur = cur + (be - bs)
        if _d(stated_end) != cur:
            problems.append(f"{name} ends {stated_end.strip()}, derived {cur:%-d %b %Y}")
    total = sum(int(h) for _, h, _, _ in rows)
    stated_total = int(re.search(r'^(\d+) hours;', road, flags=re.M).group(1))
    if total != stated_total:
        problems.append(f"phase hours sum to {total}, document states {stated_total}")
except (AttributeError, ValueError, TypeError) as e:
    problems.append(f"could not parse the schedule inputs: {e}")
check("schedule", problems,
      f"{len(rows)} phases, dates re-derive from hours and capacity")

# --- 11. criteria belong to the requirement above them -----------------------
# Appending to the end of an area silently orphans a trailing criterion: the new
# requirement inherits it. This has happened twice (FR-RCP-20, FR-HH-24). The
# misplacement is semantic, but it leaves a mechanical trace - a criterion that
# shares no vocabulary with the statement it is supposed to test. Zero overlap
# means the criterion is either attached to the wrong requirement or worded so it
# never names what it checks. Both are worth fixing.
STOP = set("a an the and or of to in is are be that which when then given it its "
           "for with on at by from as not no any every each their this those "
           "there".split())

def _stem(w):
    for suf in ("ing", "ed", "es", "s"):
        if len(w) > 4 and w.endswith(suf):
            return w[:-len(suf)]
    return w

def _toks(text):
    text = re.sub(r'\*(Given|when|then)\*', '', text)
    words = re.findall(r'`[^`]+`|\b[A-Za-z][A-Za-z-]{3,}\b', text)
    return {_stem(w.lower().strip('`.,;:\u2014-"()')) for w in words} - STOP

problems = []
n_criteria = 0
current = None
for i, line in enumerate(req_src.splitlines(), 1):
    m = re.match(r'^- \*\*((?:FR|NFR)-[A-Z0-9]+-\d+)\*\* `\w+` (.+)$', line)
    if m:
        current = m.groups()
        continue
    if re.match(r'^\s+- \*Given\*', line):
        n_criteria += 1
        if current is None:
            problems.append(f"line {i}: criterion with no requirement above it")
        elif not (_toks(current[1]) & _toks(line)):
            problems.append(f"{current[0]} (line {i}): criterion shares no wording "
                            f"with the requirement it tests")
check("criteria", problems,
      f"{n_criteria} criteria, each sharing vocabulary with its requirement")

# --- 12. coverage tally (informational) --------------------------------------
if not QUIET:
    bullets = collections.Counter()
    feature = None; in_req = False
    for line in ux.splitlines():
        if line.startswith("#### "):
            feature = line[5:].strip(); in_req = False
        elif line.startswith("##### Requirements"):
            in_req = True
        elif line.startswith("##### "):
            in_req = False
        elif in_req and line.startswith("- "):
            bullets[feature] += 1
    print()
    print(f"      intent bullets: {sum(bullets.values())} across {len(bullets)} features")
    print(f"      requirements  : {len(defined)} across {len(by_area)} areas")
    print("      (the intent-to-requirement match is semantic - run the coverage-audit skill)")

print()
if failures:
    print(f"FAILED: {', '.join(failures)}")
    sys.exit(1)
print("All structural checks passed.")
PY
