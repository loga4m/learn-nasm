# NASM Practice Problems — Calibrated to Tutorial Style
> Platform: Windows x86-64, GoLink  
> Output method: `ExitProcess` with result in `rcx` — verify with `echo %ERRORLEVEL%`  
> Template for all problems below

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

    mov rcx, rax        ; put result in rcx
    call ExitProcess
```

---

## Conditions

### C1: Max of Two
`eax = 14`, `ebx = 27`. Store the larger value in `ecx`. Exit with it.  
Expected: `%ERRORLEVEL%` = 27.

---

### C2: Sign Check
`eax = -3`. If negative, store `0` in `ecx`. If zero, store `1`. If positive, store `2`. Exit with `ecx`.  
Expected: 0.

---

### C3: Clamp
`eax = 150`. Clamp it to range [0, 100]: if above 100 set to 100, if below 0 set to 0, otherwise keep as-is. Store in `ecx`. Exit.  
Expected: 100.  
Test again with `eax = -5` (expected: 0) and `eax = 50` (expected: 50).

---

### C4: Even or Odd
`eax = 7`. If even store `0` in `ecx`, if odd store `1`. Exit with `ecx`.  
**Hint:** `test eax, 1` checks the lowest bit.  
Expected: 1.

---

### C5: Max of Three
`eax = 10`, `ebx = 35`, `ecx = 22`. Store the largest in `edx`. Exit with `edx`.  
Expected: 35.

---

## Loops

### L1: Sum of Array
Array in `.data`: `arr dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10`  
Sum all elements. Store result in `ecx`. Exit.  
Expected: 55.

**Hint:** Use a counter register and `lea` or indexed addressing like `[arr + rsi*4]`.

---

### L2: Count Negatives
Array: `arr dd 3, -1, 7, -4, 0, -2, 5`  
Count how many elements are negative. Exit with count.  
Expected: 3.

---

### L3: Find Maximum in Array
Array: `arr dd 4, 17, 2, 99, 31, 8`  
Find the maximum element. Exit with it.  
Expected: 99.

---

### L4: Count Until Condition
Starting from `eax = 1`, keep doubling (`shl eax, 1`) and count iterations until `eax` exceeds 1000. Exit with the iteration count.  
Expected: 10.  
(This is a direct extension of the `for_loop.asm` tutorial — make sure you understand that one first.)

---

### L5: Sum of Even Elements
Array: `arr dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10`  
Sum only the even elements. Exit with result.  
Expected: 30.

---

### L6: Reverse Array In-Place
Array: `arr dd 1, 2, 3, 4, 5`  
Reverse it in-place using two index pointers (start and end).  
After reversal, exit with the first element — should be 5.

---

## Mixed (Conditions + Loops)

### M1: Count Positives and Negatives
Array: `arr dd 3, -1, 0, 7, -4, 2, -2`  
Store count of positives in `eax`, count of negatives in `ebx`. Exit with `eax` (positives).  
Expected: 3.

---

### M2: First Negative Index
Array: `arr dd 5, 3, 8, -2, 1, -7`  
Find the index (0-based) of the first negative element. If none, exit with 255.  
Expected: 3.

---

### M3: Clamp All Elements
Array: `arr dd -5, 3, 150, 0, 200, 50` (in `.data`, mutable)  
Clamp every element to [0, 100] in-place. Exit with the sum of clamped values.  
Expected: clamped array is `0, 3, 100, 0, 100, 50` → sum = 253.

---

## Procedures (if covered)

### P1: Procedure — Absolute Value
Write a procedure `abs_val`:
- Argument in `rcx`
- Returns absolute value in `rax`
- Uses `sub rsp, 40` / `add rsp, 40` for shadow space

Call it from `_start` with `rcx = -42`. Exit with result.  
Expected: 42.

---

### P2: Procedure — Sum Array
Write a procedure `sum_array`:
- `rcx` = address of array, `rdx` = element count
- Returns sum in `rax`

Call with the 10-element array from L1. Exit with sum.  
Expected: 55.
