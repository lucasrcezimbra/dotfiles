# ADF (Atlassian Document Format)

ADF is the JSON document format used for Jira descriptions. Every document has this root:

```json
{ "type": "doc", "version": 1, "content": [ ...blocks ] }
```

## Block Types

**Paragraph:**
```json
{ "type": "paragraph", "content": [{ "type": "text", "text": "Hello" }] }
```

**Heading** (levels 1–6):
```json
{ "type": "heading", "attrs": { "level": 2 }, "content": [{ "type": "text", "text": "Title" }] }
```

**Bullet list:**
```json
{ "type": "bulletList", "content": [
  { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Item" }] }] }
]}
```

**Ordered list:**
```json
{ "type": "orderedList", "content": [
  { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Step 1" }] }] }
]}
```

**Code block:**
```json
{ "type": "codeBlock", "attrs": { "language": "python" }, "content": [{ "type": "text", "text": "print('hi')" }] }
```

**Blockquote:**
```json
{ "type": "blockquote", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "A quote" }] }] }
```

**Table:**
```json
{ "type": "table", "content": [
  { "type": "tableRow", "content": [
    { "type": "tableHeader", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Col" }] }] }
  ]},
  { "type": "tableRow", "content": [
    { "type": "tableCell", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Val" }] }] }
  ]}
]}
```

**Horizontal rule:**
```json
{ "type": "rule" }
```

## Inline Marks

Apply marks to text nodes for formatting:

```json
{ "type": "text", "text": "bold", "marks": [{ "type": "strong" }] }
{ "type": "text", "text": "italic", "marks": [{ "type": "em" }] }
{ "type": "text", "text": "struck", "marks": [{ "type": "strike" }] }
{ "type": "text", "text": "code", "marks": [{ "type": "code" }] }
{ "type": "text", "text": "link", "marks": [{ "type": "link", "attrs": { "href": "https://example.com" } }] }
```

Marks can be combined: `"marks": [{ "type": "strong" }, { "type": "em" }]`
