.arm

.extern main
.extern c_swi_handler
.extern c_int_handler

.section .text
.global start
start:    b reset
          b und   + TEXT
          b swi   + TEXT
          b pabt  + TEXT
          b dabt  + TEXT
          b .      
          b int   + TEXT
          b fiq   + TEXT
end:      nop

remap:    ldr    r0, =start      /* Source */
          ldr    r2, =end   
          sub    r1, r1, r1      /* Destination: 0x0 */

/* 0x0 is writeable,
   replace the vectors */

copy:     ldmia   r0!, {r3-r10}  /* Load list of registers */
                                 /* ldm{ia}, {ia} increment after */
          stmia   r1!, {r3-r10}  /* Store list of registers */
     
          cmp   r0, r2
          ble   copy

/* Call to the main program at last */

          bl    main
          b     .

          /* Stack (System mode) */

reset:    msr    CPSR_c, #0xdf
          mov    sp, #0x04 << 24

          /* Stack (IRQ mode) */
   
          msr    CPSR_c, #0xd2
          mov    sp, #0x04 << 16

          /* Stack (Abort mode) */

          msr    CPSR_c, #0xd7
          mov    sp, #0x04 << 24

          /* Stack (Super mode) */

          msr   CPSR_c, #0xd3
          mov   sp, #0x04 << 24
          b     remap

.global syscall
syscall:  push  {fp, lr}
          mov   r7, r0
          swi   0x0
          pop   {fp, pc}

         /* Stack (Use mode) */

.global usr
usr:     msr   CPSR_c, #0xd0
         mov   sp, #0x10000
               

/* Enabling global interrupts
 * IRQ 0x80/FIQ 0x40
 */

.global sti
sti:      mrs    r1, CPSR
          bic    r1, r1, #0x80
          msr    CPSR_c, r1
          bx     lr

/* Disabling global interrupts
 * IRQ 0x80/FIQ 0x40
 */

.global cli
cli:      mrs     r1, CPSR
          orr     r1, r1, #0x80
          msr     CPSR_c, r1
          bx      lr


/* When handling an ARM exception the core:
 * 1. Preserves the address of the next instruction in the appropriate LR.
 * 2. Copies the CPSR into the appropriate SPSR.
 * 3. Forces the CPSR mode bits to a value that depends on the exception.
 * 4. Forces the PC to fetch the next instruction from the relevant vector:
 */

und:

/* We are in supervisor mode.
 * IRQs are disabled when a software interrupt occurs
 */

swi:      push  {r0-r12, lr}
          bl    c_swi_handler
          pop   {r0-r12, lr}
          movs  pc, lr

pabt:
dabt:

/* We are in IRQ mode */

int:      push   {r0-r12, lr}
          bl     c_int_handler
          pop    {r0-r12, lr}
          subs   pc, lr, #4

fiq:

/* 5. Move the LR, minus an offset to the PC.
 * 6. If S bit is set and rd = r15, the core copies the SPSR back to CPSR
 */

/* Return the program status register.
 * The core contains one CPSR, and five SPSRs for exception
 * handlers to use.
 */

.global cpsr
cpsr:     mrs   r0, CPSR
          bx    lr

.global spsr
spsr:     mrs   r0, SPSR
          bx    lr

.end
