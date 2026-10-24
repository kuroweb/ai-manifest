# GitHubレビューコメントの型

## 文書構成

`code-reviewing` の本文を、次の形で出す。`<details>` は一つにする。`open` は付けない。

```html
<details>
<summary>Merge Risk：[リスクレベル]</summary>

[本文]

</details>
```

### Merge Risk

閉じたときに見える行。

```markdown
Merge Risk：[全体のリスクレベル]
```

- `[全体のリスクレベル]` は、`code-reviewing` の本文にある `**リスクレベル**:` の値を、そのまま書く
- 書き換えない

### 本文

`<summary>` のあとに、`code-reviewing` の本文を入れる。

```markdown
[code-reviewingの本文]
```

- 見出し、文言、順序、コードブロックのインデントは変えない
- `</summary>` の次の行は空行にする。空行が無いと、GitHubが中の見出し、リスト、コードブロックを描画しない
