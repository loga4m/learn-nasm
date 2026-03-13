# NASM Concepts: Structs & Macros
> Platform: Windows x86-64, GoLink  
> Output method: `ExitProcess` with result in `rcx` — verify with `echo %ERRORLEVEL%`

---

## Structs

### What a Struct Is at the Machine Level

A struct is a contiguous block of memory with named, fixed offsets. NASM doesn't generate any code for struct definitions — `struc`/`endstruc` is a directive block that creates symbolic constants for field offsets. All field access reduces to `[base + offset]` addressing.

---

### Defining a Struct: `struc` / `endstruc`

```nasm
struc Point
    .x: resd 1      ; offset 0, 4 bytes
    .y: resd 1      ; offset 4, 4 bytes
endstruc
```

After this definition, `Point.x = 0` and `Point.y = 4` are numeric constants — nothing more. `Point_size` (automatically generated) holds the total size in bytes: 8.

Field labels use dot notation (`.x`, `.y`) to scope them under the struct name. Outside the block, they're referenced as `Point.x`, `Point.y`.

---

### Allocating and Accessing a Struct Instance

**Static allocation in `.data` or `.bss`:**

```nasm
section .data
    p1: istruc Point
        at Point.x, dd 10
        at Point.y, dd 20
    iend
```

`istruc`/`iend` is syntactic sugar for laying out fields at the correct offsets. You can also do it manually:

```nasm
    p1: dd 10, 20       ; identical result — p1+0 = x, p1+4 = y
```

**Stack allocation:**

```nasm
sub rsp, Point_size     ; reserve space
lea rax, [rsp]          ; rax = pointer to struct
mov dword [rax + Point.x], 10
mov dword [rax + Point.y], 20
```

**Accessing fields via a register pointer:**

```nasm
lea rax, [p1]           ; rax = base address of p1
mov ecx, [rax + Point.x]   ; load x field
mov edx, [rax + Point.y]   ; load y field
add ecx, edx
```

---

### Alignment

The CPU accesses memory most efficiently when a field is aligned to its own size: a 4-byte field at a 4-byte boundary, an 8-byte field at an 8-byte boundary. Misaligned access is legal on x86-64 but slower (and can fault on other architectures).

`alignb N` in a struct definition inserts padding bytes to reach the next multiple of N:

```nasm
struc Mixed
    .flag:  resb 1      ; offset 0, 1 byte
    alignb 4            ; 3 bytes of padding inserted
    .value: resd 1      ; offset 4, 4 bytes
    .ptr:   resq 1      ; offset 8, 8 bytes
endstruc
; Mixed_size = 16
```

Without `alignb 4`, `.value` would sit at offset 1 — misaligned for a 32-bit load.

**Rule of thumb for struct field ordering:** largest fields first to minimize padding. This is the same rule C compilers apply.

```nasm
; Wasteful — 7 bytes padding total
struc Bad
    .a: resb 1
    .b: resq 1      ; needs 8-byte alignment → 7 bytes padding
    .c: resd 1
endstruc            ; size = 24

; Efficient — 0 bytes padding
struc Good
    .b: resq 1      ; offset 0
    .c: resd 1      ; offset 8
    .a: resb 1      ; offset 12
    ; 3 bytes implicit tail padding to align size to 8
endstruc            ; size = 16
```

---

### Nested Structs

NASM has no native nested struct syntax. Flatten manually:

```nasm
struc Inner
    .val: resd 1        ; size = 4
endstruc

struc Outer
    .count: resd 1      ; offset 0
    alignb 4
    .inner_val: resd 1  ; offset 4 — manually inlined Inner.val
endstruc
```

Or use an offset constant: `OUTER_INNER_OFFSET equ 4`.

---

### Array of Structs

```nasm
section .data
    pts: times 3 db 0       ; reserve 3 * Point_size bytes (wrong — use istruc or dd)
    ; Correct:
    pt0: dd 1, 2
    pt1: dd 3, 4
    pt2: dd 5, 6
```

Indexing into an array of structs of size S at index i: `base + i * S + field_offset`.

```nasm
; Access pt1.y (i=1, S=8, field=Point.y=4)
lea rax, [pt0]
mov ecx, [rax + 1 * Point_size + Point.y]
```

---

## NASM Macros

### `%define` — Text Substitution

```nasm
%define MAX_SIZE 64
%define ARRAY_ADDR [rsp + 8]
```

Pure textual substitution before assembly. No type, no evaluation at this stage. `MAX_SIZE` is replaced with `64` wherever it appears.

Parametric form:

```nasm
%define SQ(x) ((x) * (x))
mov eax, SQ(5)          ; assembles as: mov eax, ((5) * (5))
```

Parentheses around parameters and the whole expression prevent operator precedence bugs.

---

### `%macro` / `%endmacro` — Procedural Macros

```nasm
%macro SAVE_REGS 0
    push rbx
    push rsi
    push rdi
%endmacro

%macro RESTORE_REGS 0
    pop rdi
    pop rsi
    pop rbx
%endmacro
```

The number after the macro name is the **arity** — how many arguments it takes. `0` means no arguments.

**Parameterized macro:**

```nasm
%macro LOAD_IMM 2       ; 2 arguments
    mov %1, %2          ; %1 = first arg, %2 = second arg
%endmacro

LOAD_IMM rax, 42        ; expands to: mov rax, 42
LOAD_IMM ecx, -1        ; expands to: mov ecx, -1
```

---

### Local Labels in Macros: `%%label`

Macros that contain labels must use `%%`-prefixed labels. Each macro invocation gets a unique expansion of `%%label`, preventing duplicate label errors when the macro is used more than once.

```nasm
%macro ABS_VAL 1        ; arg: register to absolutize in-place
    test %1, %1
    jge %%done
    neg %1
%%done:
%endmacro

ABS_VAL eax             ; %%done → ..@1.done (unique)
ABS_VAL ebx             ; %%done → ..@2.done (unique)
```

Without `%%`, both expansions emit the same label `done` — assembler error.

---

### Optional Arguments and Defaults

```nasm
%macro PROLOGUE 0-1 40      ; 0 to 1 args; default = 40
    sub rsp, %1
%endmacro

PROLOGUE        ; sub rsp, 40
PROLOGUE 56     ; sub rsp, 56
```

---

### `%rep` / `%endrep` — Repetition

```nasm
%rep 4
    nop
%endrep
; emits 4 nop instructions
```

Combined with a counter variable using `%assign`:

```nasm
%assign i 0
%rep 8
    mov byte [rsp + i], 0
    %assign i i+1
%endrep
```

---

### Conditional Assembly: `%if` / `%ifdef`

```nasm
%define DEBUG 1

%ifdef DEBUG
    ; these lines assembled only if DEBUG is defined
    nop
%endif

%if MAX_SIZE > 32
    ; assembled only if condition is true at assembly time
%endif
```

These are **assembly-time** conditionals — no runtime branch, no code emitted for the false branch.

---

### Macro vs Procedure: When to Use Which

| | Macro | Procedure |
|---|---|---|
| Call overhead | None — inlined | `call`/`ret`, shadow space |
| Code size | Grows with use count | Fixed, shared |
| Register preservation | Caller's responsibility (you control the expansion) | Explicit push/pop |
| Use when | Short, repeated boilerplate; needs register flexibility | Reusable logic called many times |

---

### Common Pitfall: Macro Side Effects

Macros are textual — if an argument has side effects or is a complex expression, it may be evaluated multiple times:

```nasm
%define INC_AND_USE(r) (r + 1)
; if r is a memory reference, [mem + 1] is fine
; if r is something with a side effect, beware
```

For registers as arguments this is usually safe. For memory operands, be explicit.

---

### Shadow Space Reminder

All `call` instructions on Windows x64 require 32 bytes of shadow space allocated by the **caller** before the call. The template's `sub rsp, 40` (= 32 + 8 to maintain 16-byte alignment after the implicit `push rip` from `call`) handles this for a flat `_start`. Inside procedures that themselves make calls, re-allocate shadow space.

```nasm
my_proc:
    sub rsp, 40         ; shadow space for any calls made inside
    ; ... body ...
    add rsp, 40
    ret
```
