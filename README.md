# Android Code Review Skill

A Claude Code skill untuk review kode Android secara otomatis berdasarkan git diff.

## Apa yang dicek

1. **Unused Imports** — import yang tidak lagi dipakai setelah perubahan akan dihapus otomatis
2. **Unit Test ViewModel** — jika ada ViewModel yang berubah tapi belum punya test, skill ini akan membuatkannya
3. **Unused Function/Variable** — kode yang dideklarasikan tapi tidak pernah dipakai akan dihapus

## Instalasi

```bash
git clone https://github.com/mahesariznan/android-code-review-skill.git
cd android-code-review-skill
chmod +x install.sh
./install.sh
```

Restart Claude Code atau jalankan `/reload-plugins` untuk mengaktifkan.

## Cara Pakai

Cukup bilang ke Claude Code:

```
review kode
```

atau

```
cek perubahan sebelum PR
```

Claude akan otomatis menganalisis `git diff` dan melakukan review berdasarkan 3 poin di atas.

## Uninstall

```bash
rm -rf ~/.claude/skills/android-code-review
```
