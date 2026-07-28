#!/usr/bin/env node
// 초안 마크다운 -> 네이버 스마트에디터가 받는 HTML로 변환한다.
//
//   node bin/md-to-naver.mjs <초안.md>            # HTML을 stdout 으로
//   node bin/md-to-naver.mjs <초안.md> --code     # 코드블록만 stdout 으로
//
// 스마트에디터는 <pre> <code> <table> style 을 붙여넣을 때 씹거나 깨뜨린다.
// 그래서 코드는 본문에서 떼어내 [코드블록 N] 자리표시자로 남기고,
// 사람이 에디터의 코드블록 컴포넌트에 따로 넣는다.
//
// `## 제목 후보` 섹션은 검토용이므로 붙여넣기 결과에서 제외된다.

import { readFileSync } from 'node:fs'

const path = process.argv[2]
const codeOnly = process.argv.includes('--code')
if (!path) {
  console.error('사용법: md-to-naver.mjs <초안.md> [--code]')
  process.exit(2)
}

const src = readFileSync(path, 'utf8')

const esc = (s) =>
  s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

// 인라인 서식. esc 이후에 적용해야 삽입한 태그가 다시 escape 되지 않는다.
const inline = (s) =>
  esc(s)
    .replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (_, t, u) => `<a href="${u}">${t}</a>`)
    .replace(/\*\*([^*]+)\*\*/g, '<b>$1</b>')
    .replace(/(^|[^*])\*([^*]+)\*/g, '$1<i>$2</i>')
    .replace(/`([^`]+)`/g, '<i>$1</i>')

const lines = src.split('\n')
const out = []
const codeBlocks = []
let list = null // 'ul' | 'ol' | null
let skipSection = false

const closeList = () => {
  if (list) { out.push(`</${list}>`); list = null }
}
const openList = (kind) => {
  if (list !== kind) { closeList(); out.push(`<${kind}>`); list = kind }
}

for (let i = 0; i < lines.length; i++) {
  const raw = lines[i]
  const line = raw.trim()

  // 코드 펜스 -> 자리표시자로 치환하고 내용은 따로 모은다
  const fence = line.match(/^```+\s*(\S*)/)
  if (fence) {
    const lang = fence[1] || ''
    const body = []
    i++
    while (i < lines.length && !/^```+\s*$/.test(lines[i].trim())) body.push(lines[i]), i++
    if (!skipSection) {
      codeBlocks.push({ n: codeBlocks.length + 1, lang, code: body.join('\n') })
      closeList()
      out.push(`<p><b>[코드블록 ${codeBlocks.length}]</b></p>`)
    }
    continue
  }

  const heading = line.match(/^(#{1,6})\s+(.*)$/)
  if (heading) {
    const text = heading[2]
    // 검토용 섹션은 붙여넣기 대상에서 제외
    skipSection = /^제목\s*후보/.test(text)
    closeList()
    if (!skipSection) out.push(`<h${heading[1].length >= 4 ? 4 : 3}>${inline(text)}</h${heading[1].length >= 4 ? 4 : 3}>`)
    continue
  }
  if (skipSection) continue

  if (line === '' ) { closeList(); continue }

  if (/^[-*+]\s+/.test(line)) {
    openList('ul')
    out.push(`<li>${inline(line.replace(/^[-*+]\s+/, ''))}</li>`)
    continue
  }
  if (/^\d+[.)]\s+/.test(line)) {
    openList('ol')
    out.push(`<li>${inline(line.replace(/^\d+[.)]\s+/, ''))}</li>`)
    continue
  }
  if (/^>\s?/.test(line)) {
    closeList()
    out.push(`<blockquote>${inline(line.replace(/^>\s?/, ''))}</blockquote>`)
    continue
  }
  if (/^(---+|===+|\*\*\*+)$/.test(line)) { closeList(); continue } // 구분선은 버린다

  closeList()
  out.push(`<p>${inline(line)}</p>`)
}
closeList()

if (codeOnly) {
  if (!codeBlocks.length) { console.error('코드블록이 없다.'); process.exit(1) }
  for (const b of codeBlocks) {
    console.log(`===== [코드블록 ${b.n}]${b.lang ? ` (${b.lang})` : ''} =====`)
    console.log(b.code)
    console.log()
  }
} else {
  console.log(out.join('\n'))
}
