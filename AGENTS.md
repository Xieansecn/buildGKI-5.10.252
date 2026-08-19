# AGENTS.md — buildGKI-5.10.252 (PixelOS marble GKI kernel)

## Project Overview

CI-only repository that builds a **custom GKI kernel for PixelOS on marble
(Poco F5 / Redmi Note 12 Turbo)** with KernelSU / KernelSU-Next / ReSukiSU
integrated. The stock PixelOS kernel is a pure Google GKI build
(`5.10.252-gki-...`, `nobody@android-build`), so this repo builds the generic
GKI kernel from `android.googlesource.com/kernel/common` and replaces **only
the kernel inside the `boot` partition**.

**No kernel sources are stored here.** Everything (kernel tree, toolchain,
root managers) is fetched at build time by the workflow.

## How to Build (GitHub Actions)

1. **Actions → build PixelOS GKI kernel (KernelSU/ReSukiSU) → Run workflow.**
2. Choose the root manager: `kernelsu` / `kernelsu-next` / `resukisu`.
3. `enable_susfs`: off by default (SUSFS is only supported by `kernelsu-next`
   via external Simonpunk patch, or `resukisu` built-in).
4. `lto`: `thin` (default, safe on free runners) / `none` / `full`.
5. Artifact: **`GKI-Image`** — the raw kernel image (5.10.252 + chosen root).

## Key Facts (verified)

| Item | Value |
|------|-------|
| Stock kernel | 5.10.252-gki-gf3f02401fb28 (GKI `android12-5.10-2026-04_r1`) |
| Kernel source | `kernel/common` tag `android12-5.10-2026-04_r1` (SUBLEVEL=252) |
| Toolchain | Android official prebuilt clang (`clang-r547379`) |
| vendor_boot | 14 DTBs — **never touched** (dtb stays stock) |
| vendor_dlkm | fingerprint + vendor modules — **never touched** |
| boot partition | hdr v4, kernel + generic ramdisk, no DTB |

## Build Pipeline

```
Checkout repo
  → free disk space
  → swap (if LTO)
  → cached apt deps (bc/bison/flex/libelf/libssl/pahole/...)
  → libncurses5 (needed by Android prebuilt clang.real)
  → download official prebuilt clang-r547379 (complete toolchain)
  → clone kernel/common @ android12-5.10-2026-04_r1
  → verify kernel version == 5.10.252
  → integrate KernelSU/KernelSU-Next/ReSukiSU (setup.sh)
  → (optional) external SUSFS for kernelsu-next
  → gki_defconfig + enable KSU/KPROBES/KALLSYMS (+LTO selection)
  → make Image (CROSS_COMPILE=aarch64-linux-gnu- LLVM=1)
  → verify Image version string
  → upload GKI-Image
```

## Flashing

The artifact is a **raw kernel Image**, not a boot.img. Flash it by replacing
the kernel inside the stock `boot.img`:

```bash
magiskboot unpack boot.img
cp GKI-Image kernel
magiskboot repack boot.img   # -> new-boot.img
fastboot flash boot new-boot.img
```

**Do NOT touch `vendor_boot` / `dtbo` / `vendor_dlkm`** — they stay stock and
therefore stay matched with the kernel.

## Conventions

- Only file that matters: `.github/workflows/pixelOS_kernel.yaml`.
- No patches, fragments, or config files are stored in this repo.
- Manual trigger (`workflow_dispatch`) only.
- Branch: `main`.
