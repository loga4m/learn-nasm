## Stack alignment

- Windows requires 16-byte alignment: RSP % 16 == 0 (RSP & 0xF == 0)
- Function call:
  - before: stack is aligned
  - after: stack is misaligned -- RSP := RSP - 8
    - (push 8 byte address and you move to lower address since stack grows downward)
    - now the calle must allocate shadow spacing + must align 
- Shadow space: space for first 4 args.
- Alignment: 32 + args_nums*8 + [0 or 8] (alignment)
  - Explanation:
