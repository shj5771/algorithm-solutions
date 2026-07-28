#!/usr/bin/env bash
# 초안 HTML을 macOS 클립보드에 서식 있는 텍스트(RTF)로 올린다.
# 네이버 스마트에디터에 그대로 붙여넣으면 제목/목록/굵기가 유지된다.
#
#   사용법: bin/copy-draft.sh drafts/2026-07-28-programmers-42586.html
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "사용법: $(basename "$0") <초안.html>" >&2
  exit 2
fi

draft=$1
if [[ ! -f $draft ]]; then
  echo "파일이 없다: $draft" >&2
  exit 1
fi

textutil -stdin -format html -convert rtf -stdout < "$draft" | pbcopy -Prefer rtf

echo "복사됨: $draft"

# 코드는 스마트에디터의 '코드블록' 컴포넌트에 따로 넣어야 서식이 산다.
code=${draft%.html}.code.md
if [[ -f $code ]]; then
  echo
  echo "코드 스니펫은 따로 있다 — 본문의 [코드블록 N] 자리에 넣어라:"
  echo "  $code"
fi
