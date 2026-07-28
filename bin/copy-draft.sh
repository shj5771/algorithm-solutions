#!/usr/bin/env bash
# 초안 마크다운을 네이버 스마트에디터에 붙여넣을 수 있게 클립보드에 올린다.
#
#   사용법: bin/copy-draft.sh drafts/2026-07-28-programmers-178870.md
#           bin/copy-draft.sh drafts/....md --code   # 코드블록만 (평문)
#
# 클립보드에 HTML 플레이버(«class HTML»)와 평문을 함께 올린다.
# RTF(textutil)는 쓰지 않는다 — 다크모드일 때 색상표에 흰 글자색을 박아서
# 네이버에 붙이면 흰 글자 / 검은 배경으로 나온다. HTML은 색을 싣지 않으므로
# 에디터가 자기 스타일을 적용한다.
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
  # 코드는 서식 없는 평문으로. 에디터 코드블록에 그대로 들어가야 한다.
  node "$here/md-to-naver.mjs" "$draft" --code | pbcopy
  echo "코드블록을 클립보드에 복사했다 (평문)."
  echo "스마트에디터에서 코드블록 컴포넌트를 열고 붙여넣어라."
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

node "$here/md-to-naver.mjs" "$draft"          > "$tmp/body.html"
node "$here/md-to-naver.mjs" "$draft" --text   > "$tmp/body.txt"

hex=$(xxd -p < "$tmp/body.html" | tr -d '\n')

# AppleScript 로 HTML + 평문 두 플레이버를 동시에 올린다.
# 평문은 파일에서 읽어 인용 부호 이스케이프 문제를 피한다.
cat > "$tmp/set.applescript" <<APPLESCRIPT
set plainText to read POSIX file "$tmp/body.txt" as «class utf8»
set the clipboard to {«class HTML»:«data HTML${hex}», string:plainText}
APPLESCRIPT

osascript "$tmp/set.applescript"

echo "본문을 클립보드에 복사했다: $draft"
echo "  플레이버: $(osascript -e 'clipboard info' | tr ',' '\n' | grep -oE '«class HTML»|Unicode text' | sort -u | tr '\n' ' ')"
echo

n=$(grep -c '\[코드블록' "$tmp/body.html" || true)
if [[ $n -gt 0 ]]; then
  echo "본문에 [코드블록] 자리표시자가 ${n}개 있다. 그 자리에 코드를 넣어라:"
  echo "  bin/copy-draft.sh $draft --code"
fi
