#!/usr/bin/env bash
# 초안 마크다운을 네이버 스마트에디터에 붙여넣을 수 있게 클립보드에 올린다.
# 마크다운 -> 스마트에디터용 HTML -> RTF 로 변환하므로 서식이 유지된다.
#
#   사용법: bin/copy-draft.sh drafts/2026-07-28-programmers-178870.md
#           bin/copy-draft.sh drafts/....md --code   # 코드블록만 클립보드에
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [[ $# -lt 1 ]]; then
  echo "사용법: $(basename "$0") <초안.md> [--code]" >&2
  exit 2
fi

draft=$1
mode=${2:-}

if [[ ! -f $draft ]]; then
  echo "파일이 없다: $draft" >&2
  exit 1
fi

if [[ $mode == "--code" ]]; then
  # 코드는 서식 없는 평문으로 복사한다. 에디터 코드블록에 그대로 들어가야 한다.
  node "$here/md-to-naver.mjs" "$draft" --code | pbcopy
  echo "코드블록을 클립보드에 복사했다 (평문)."
  echo "스마트에디터에서 코드블록 컴포넌트를 열고 붙여넣어라."
  exit 0
fi

node "$here/md-to-naver.mjs" "$draft" \
  | textutil -stdin -format html -convert rtf -stdout \
  | pbcopy -Prefer rtf

echo "본문을 클립보드에 복사했다 (서식 유지): $draft"
echo

n=$(node "$here/md-to-naver.mjs" "$draft" | grep -c '\[코드블록' || true)
if [[ $n -gt 0 ]]; then
  echo "본문에 [코드블록] 자리표시자가 ${n}개 있다. 그 자리에 코드를 넣어라:"
  echo "  bin/copy-draft.sh $draft --code"
fi
