# Windows x64 ABI Calling Convention Cheatsheet

---

## Integer / Pointer Arguments

| Arg # | Register |
|-------|----------|
| 1     | `RCX`    |
| 2     | `RDX`    |
| 3     | `R8`     |
| 4     | `R9`     |
| 5+    | Stack (right-to-left push order, but laid out left-to-right at RSP+32, RSP+40, …) |

- Arguments are **passed by value** if ≤ 64 bits.
- Structs/unions **≤ 8 bytes**: passed as integer in register if size is 1, 2, 4, or 8 bytes exactly; otherwise by pointer.
- Structs **> 8 bytes**: caller allocates, passes pointer in the register slot.

---

## Floating-Point Arguments

| Arg # | Register  |
|-------|-----------|
| 1     | `XMM0`    |
| 2     | `XMM1`    |
| 3     | `XMM2`    |
| 4     | `XMM3`    |
| 5+    | Stack     |

- FP and integer slots are **positional and exclusive**: if arg 1 is float, `XMM0` is used and `RCX` is **shadowed** (undefined/ignored by callee). If arg 2 is integer, `RDX` is used and `XMM1` is shadowed.
- Variadics: FP args must be duplicated in both XMM and integer register for `...` params.

---

## Return Values

| Type                        | Location         |
|-----------------------------|------------------|
| Integer/pointer ≤ 64 bits   | `RAX`            |
| Float/double                | `XMM0`           |
| `__m128` / `__m256`         | `XMM0`           |
| Struct 1/2/4/8 bytes        | `RAX`            |
| Struct > 8 bytes            | Caller allocates; pointer passed as **hidden first arg** in `RCX`; `RAX` returns that pointer |

---

## Shadow Space (Home Space)

- Caller **must** allocate 32 bytes (`4 × 8`) on the stack **above the return address** before `CALL`, even if the callee takes < 4 args or none.
- These slots (`[RSP+8]`…`[RSP+32]` from callee's frame view) belong to the callee — it may spill RCX/RDX/R8/R9 there.
- The 32 bytes are **not** initialized by the caller; they're scratch for the callee.

```
Caller stack layout before CALL:
  [RSP+40] = 6th arg (if any)
  [RSP+32] = 5th arg (if any)
  [RSP+24] = shadow (R9 home)
  [RSP+16] = shadow (R8 home)
  [RSP+ 8] = shadow (RDX home)
  [RSP+ 0] = shadow (RCX home)   ← RSP here when callee begins
  [RSP- 8] = return address      ← after CALL, RSP -= 8
```

Wait — corrected layout from **callee's perspective** (after `CALL` executes, RSP points to return address):

```
Callee's RSP view after CALL:
  [RSP+ 0] = return address
  [RSP+ 8] = RCX home (shadow)
  [RSP+16] = RDX home (shadow)
  [RSP+24] = R8  home (shadow)
  [RSP+32] = R9  home (shadow)
  [RSP+40] = 5th arg (if any)
  [RSP+48] = 6th arg (if any)
  ...
```

---

## Stack Alignment

- RSP must be **16-byte aligned** at the point of `CALL` (i.e., `RSP % 16 == 8` just before `CALL` executes, because `CALL` pushes 8 bytes).
- After function prologue (`PUSH RBP` etc.), maintain 16-byte alignment for local frame.
- Misalignment causes `#GP` or silent corruption in SSE/AVX operations.

**Rule of thumb**: Before `CALL`, `(RSP - 8) % 16 == 0`. If you've pushed an odd number of 8-byte values since the last alignment point, insert a `SUB RSP, 8` dummy pad.

---

## Volatile vs. Non-Volatile Registers

### Volatile (caller-saved) — callee may trash freely

| Integer          | FP/Vector                   |
|------------------|-----------------------------|
| `RAX`            | `XMM0`–`XMM5`              |
| `RCX`, `RDX`     | `YMM0`–`YMM5` (upper halves) |
| `R8`–`R11`       | `ZMM0`–`ZMM5`, `ZMM16`–`ZMM31` |
| `FLAGS`          | `XMM6`–`XMM15` **lower 128b are non-volatile** |

### Non-Volatile (callee-saved) — callee must preserve

| Integer                        | FP/Vector               |
|--------------------------------|-------------------------|
| `RBX`, `RBP`, `RDI`, `RSI`    | `XMM6`–`XMM15` (full)  |
| `R12`–`R15`                    | `YMM6`–`YMM15` (upper 128b) |
| `RSP` (implicitly)             |                         |

> **Note**: `RDI` and `RSI` are **non-volatile** in Windows x64 (opposite of System V AMD64).

---

## Function Prologue / Epilogue Pattern

```asm
; Minimal prologue
push    rbp
mov     rbp, rsp
sub     rsp, N          ; N = local space + shadow space, must keep RSP 16-aligned

; Save non-volatile regs you use
push    rbx
push    r12
; ...

; === function body ===

; Epilogue
pop     r12
pop     rbx
mov     rsp, rbp        ; or: add rsp, N
pop     rbp
ret
```

For **leaf functions** (no calls, no exception handling): prologue/epilogue may be omitted if RSP is untouched — but shadow space still needed if you call anything.

---

## Unwind Data (SEH)

- Non-leaf functions **must** register unwind info (`.pdata` / `.xdata` sections) for structured exception handling and stack walkers.
- MASM: use `PROC FRAME` + `[UNWIND_INFO]` directives.
- NASM/raw: emit `.pdata` manually with `RUNTIME_FUNCTION` entries pointing to unwind codes.
- Leaf functions (no RSP modification, no calls) are exempt.

---

## Calling Conventions for `__stdcall`, `__cdecl`, `__fastcall` (x86 32-bit)

> Applies to 32-bit code only. In x64, there is **one** calling convention.

| Convention    | Args          | Stack cleanup | Notes                         |
|---------------|---------------|---------------|-------------------------------|
| `__cdecl`     | Stack R→L     | Caller        | Default C; supports variadics |
| `__stdcall`   | Stack R→L     | Callee        | WinAPI default                |
| `__fastcall`  | ECX, EDX, then stack R→L | Callee | MSVC fastcall         |
| `__thiscall`  | `this` in ECX, stack R→L | Callee | MSVC C++ methods       |

---

## System Calls (Windows)

- Windows does **not** expose a stable syscall interface — use `ntdll` via normal ABI.
- Syscall numbers change between OS versions.
- Direct `syscall` instruction: only legitimate in `ntdll.dll` stubs; using it elsewhere is unsupported and breaks on updates.

---

## Key Differences vs. System V AMD64 (Linux)

| Feature              | Windows x64          | System V AMD64 (Linux) |
|----------------------|----------------------|------------------------|
| Int arg regs         | RCX RDX R8 R9        | RDI RSI RDX RCX R8 R9  |
| FP arg regs          | XMM0–XMM3            | XMM0–XMM7              |
| Shadow space         | 32 bytes required    | None                   |
| RDI / RSI            | Non-volatile         | Volatile                |
| Red zone             | None                 | 128 bytes below RSP     |
| Struct return hidden | RCX (1st slot)       | RDI (before other args) |
| XMM6–XMM15           | Non-volatile         | Volatile                |

---

## Quick Reference Card

```
ARGS (int):    RCX  RDX  R8   R9   [RSP+40] [RSP+48] ...
ARGS (fp):     XMM0 XMM1 XMM2 XMM3  (same stack slots)
RETURN int:    RAX
RETURN fp:     XMM0
SHADOW:        32 bytes (RSP+8 .. RSP+32 from callee view)
ALIGN:         RSP % 16 == 0 before CALL (i.e., == 8 just before push of ret addr)
VOLATILE:      RAX RCX RDX R8-R11 XMM0-XMM5
NONVOLATILE:   RBX RBP RSI RDI R12-R15 XMM6-XMM15
```
