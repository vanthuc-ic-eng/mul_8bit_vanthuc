# Git freeze / version control: v0.1.0-lut-only-zybo

From the clean `mul_int8/` project root, after `make check`, and preferably
**after running `make sim`, `make fpga-pair`, `make asic-pair`, `make sta-pair`**:

```bash
git init
git branch -M main
git add .
git status --short
git commit -m "release(v0): signed LUT-ALM V0 and exact, Zybo LUT-only DSP=0"
git tag -a v0.1.0-lut-only-zybo -m "Frozen verified source: LUT-ALM V0, Zybo, DSP=0"
git tag --list
```

If `git commit` asks for identity:

```bash
git config user.name "YOUR NAME"
git config user.email "YOUR EMAIL"
```

Remote (after creating your private GitHub repository):

```bash
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main
git push origin v0.1.0-lut-only-zybo
```

Source files, Nangate45 normal.lib and golden vectors are tracked. Generated
`build/`, `reports/` and Vivado caches are ignored to ensure repeatability.
Use a new branch for LUT-ALM 1:

```bash
git switch -c feature/lutalm-v1
```

Never overwrite this V0 tag after freezing. Tagging does not certify that PPA
matches a third-party baseline. Attach your measured reports as release assets,
or store them in a separately versioned measurement archive if needed.
