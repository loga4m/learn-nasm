# NASM Practice Problems — Structs & Macros
> Platform: Windows x86-64, GoLink  
> Output method: `ExitProcess` with result in `rcx` — verify with `echo %ERRORLEVEL%`

```nasm
; template.asm
; nasm -f win64 template.asm -o template.obj
; golink /console /entry _start template.obj kernel32.dll /fo template.exe
default rel
extern ExitProcess
section .data
    ; your data here
section .text
global _start
_start:
    sub rsp, 40

    ; your code here

    mov rcx, rax
    call ExitProcess
```

---

## Structs

### S1: Define and Read a Point
Define a `Point` struct with fields `x` and `y` (each `dd`, 4 bytes).  
Declare a static instance `p1` with `x = 7`, `y = 13`.  
Load `p1.x` into `eax`, `p1.y` into `ebx`. Add them. Exit with the sum.  
Expected: 20.

---

### S2: Modify a Field
Same `Point` struct.  
Declare `p1` with `x = 3`, `y = 9`.  
Load `p1.x` into a register, double it, store back into `p1.x`.  
Load `p1.x` + `p1.y`. Exit with the result.  
Expected: `(3 * 2) + 9 = 15`.

---

### S3: Pointer-Based Field Access
Define a `Rect` struct:
```
.left   dd  (4 bytes)
.top    dd  (4 bytes)
.right  dd  (4 bytes)
.bottom dd  (4 bytes)
```
Declare a static instance with values `left=2, top=5, right=10, bottom=20`.  
Use `lea rax, [rect_instance]` to get a pointer.  
Access `right` and `bottom` through `rax` (i.e., `[rax + Rect.right]`).  
Compute width = `right - left` and height = `bottom - top` using pointer-based loads.  
Exit with `width + height`.  
Expected: `8 + 15 = 23`.

**Constraint:** no direct label references after `lea` — all field reads must go through `rax`.

---

### S4: Alignment Padding
Define a struct `Mixed`:
```
.flag   resb 1      ; 1 byte
alignb 4
.value  resd 1      ; 4 bytes
.big    resq 1      ; 8 bytes
```
Declare a static instance. Set `flag = 1`, `value = 100`, `big` can be zero.  
Verify your struct works by loading `value` (not `flag`) via a pointer and exiting with it.  
Expected: 100.

**Purpose:** confirm that `alignb` is placed correctly and `value` loads without corruption from the adjacent `flag` byte.

---

### S5: Array of Structs
Define a `Point` struct (`x dd`, `y dd`).  
Declare an array of 4 points in `.data`:
```
(1,2), (3,4), (5,6), (7,8)
```
Write a loop that sums all `x` fields only.  
**Constraint:** index the array using `base + i * Point_size + Point.x` — do not hardcode per-element addresses.  
Exit with the sum of x values.  
Expected: `1 + 3 + 5 + 7 = 16`.

---

### S6: Find Struct by Field Value
Same 4-point array from S5.  
Find the first `Point` whose `y` field equals 6. Exit with its `x` field.  
If no match, exit with 255.  
Expected: 5 (the point `(5,6)`).

---

## Macros

### M1: `%define` Constants
Define `%define WIDTH 80` and `%define HEIGHT 25`.  
Compute `WIDTH * HEIGHT`. Exit with the result.  
Expected: 2000.

**Note:** `imul eax, ebx` works here; no need for anything fancier.

---

### M2: Parametric `%define`
Define a macro `%define CLAMP_MAX(v, hi) ...` that expands to an inline expression capping `v` at `hi`.  
Actually: `%define` is pure text substitution and can't contain conditional logic. So instead, define:

```nasm
%define MAX_VAL 100
```

Then write a `%macro CLAMP_HIGH 1` that clamps register `%1` to `MAX_VAL` in-place (uses `cmp`/`cmov` or a conditional jump).

Call it on `eax = 150` and `ebx = 50`. Exit with `eax + ebx`.  
Expected: `100 + 50 = 150`.

---

### M3: Zero-Arg Utility Macro
Write a macro `PROLOGUE` that emits `sub rsp, 40` and a macro `EPILOGUE` that emits `add rsp, 40` followed by `ret`.

Write a procedure `square` that:
- takes argument in `rcx`
- returns `rcx * rcx` in `rax`
- uses `PROLOGUE` / `EPILOGUE`

Call it from `_start` with `rcx = 9`. Exit with result.  
Expected: 81.

---

### M4: Local Labels in Macros
Write a macro `ABS_REG 1` that takes a 32-bit register and absolutizes it in-place.  
Must use `%%`-prefixed local labels.

Invoke it twice in `_start`:
```
eax = -7  → ABS_REG eax
ebx = 3   → ABS_REG ebx
```
Exit with `eax + ebx`.  
Expected: 10.

**Verify correctness:** remove the `%%` prefix from your label, assemble again — you should get a duplicate label error. Then restore it.

---

### M5: Multi-Line Macro with Multiple Arguments
Write a macro `LOAD_AND_ADD 3`:
- `%1` = destination register (32-bit)
- `%2` = first source (immediate or register)
- `%3` = second source (immediate or register)
- Emits: `mov %1, %2` then `add %1, %3`

Use it to compute `ecx = 40 + 60`. Exit with `ecx`.  
Expected: 100.

---

### M6: `%rep` Unroll
Use `%rep` with `%assign` to emit 5 sequential `add eax, 10` instructions (i.e., unroll a loop that adds 10 five times).  
Start with `eax = 0`. Exit with result.  
Expected: 50.

---

## Mixed (Structs + Macros)

### X1: Macro-Assisted Struct Access
Define a `Point` struct.  
Write a macro `GET_X 2` where `%1` = destination register, `%2` = pointer register.  
Expands to: `mov %1, [%2 + Point.x]`.  
Similarly write `GET_Y 2`.

Declare a static `Point` with `x = 33`, `y = 44`.  
Use the macros to load both fields. Exit with `x + y`.  
Expected: 77.

---

### X2: Loop Over Array of Structs Using Macro
Define a `Point` struct.  
Write a macro `NEXT_POINT 1` that advances a pointer register by `Point_size`:  
```nasm
%macro NEXT_POINT 1
    add %1, Point_size
%endmacro
```

Declare 5 points with y-values: `2, 8, 1, 9, 4`.  
Loop through the array using a pointer register. Use `NEXT_POINT` to advance. Sum all `y` fields.  
Exit with the sum.  
Expected: `2 + 8 + 1 + 9 + 4 = 24`.

---

### X3: Struct Init Macro
Define a `Point` struct.  
Write a macro `MAKE_POINT 3` — `%1` = pointer register (already pointing to allocated memory), `%2` = x value, `%3` = y value:
```nasm
%macro MAKE_POINT 3
    mov dword [%1 + Point.x], %2
    mov dword [%1 + Point.y], %3
%endmacro
```

Allocate space for 2 points on the stack:
```nasm
sub rsp, 2 * Point_size + 8     ; +8 for 16-byte alignment
```
Use `MAKE_POINT` to initialize both:  
- Point 0: `x=5, y=10`  
- Point 1: `x=20, y=1`

Sum all four fields. Exit with result.  
Expected: `5 + 10 + 20 + 1 = 36`.

**Note:** manage the pointer carefully — `lea rax, [rsp + 8]` for point 0, `lea rbx, [rsp + 8 + Point_size]` for point 1, or advance a single register.
