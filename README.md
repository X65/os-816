# OS/816
Operating System for X65 microcomputer

Some loose notes so far, nothing of substance… yet.


## Tasks

32 available tasks (0-31)

Each task has a combined 256 bytes of direct_page+stack in Bank 0 (First 32 * 256 bytes)
and dedicated bank (data pointer and program pointer) of the task number (First 32 banks)

Task 0 (bank 0) is special, as it hosts the operating system data, thus it is not to be used freeley.
It is used by special OS task 0, which typically is a main CLI. This process needs to work together with OS in sharing bank 0 memory space to its data, OS data, shared task data, and memory-mapped devices.

Bank 255 is special, as it hosts the OS/816 itself (code and data).
OS is accessible by COP instruction trap.

### Hybrid multitasking
Time sharing is triggered by VBL, every 1/60 sec.
Task can yield cpu time by itself not waiting for preemption.

VBL interrupt routine doing time counting and task switching uses data in bank 0 (task 32 area) for bookkeeping, so it does not need to far-reach to bank 255.

## SIGnal

every task can send any signal to every other task - including STOP
Sending a signal to task 255 (-1) sends signal to every task excluding current one (self)
Sending STOP to 255 can be used i.e. by games to take-over the machine.

## SysCall

OS functions are accessed by syscall mechanizm.
The OS trap is triggered by COP instruction, with syscall number given as COP instruction argument.

A register is used for parameter passing and return value
(in case of syscalls expecting/returning 16 bit value, it is expected to enter the syscall in 16bit CPU mode)
X,Y registers are preserved
The rest of syscall arguments (if any) should be pushed to (task) stack. syscall will return with stack unwind - there is no need to pull them back after syscall.


## Virtual terminal

S device is responsible for registering screens for each task.
Every task can have its own screen: `S0` - `"S31"` (only `S0`-`S9` accessible to CLI).
Switch: `🐾1` - `🐾9`, `🐾0` and `🐾+`, `🐾-` to switch next,prev

To enable screen for task, you register: video memory addres, attribute memory address, DL address.

S device stores which terminal is currently active.
VT switch request stores next VT number in system area (bank 0) (you can just POKE it) and VBL will switch if current != wanted.
During switch handler check whether task has screen registered (video/attr/dl memory non zero) and:
1. saves current video/attr/dl address to current vt task structure
2. loads video/attr/dl address from requested task structure

Screens are hardcoded to a task. Task can have 0 or 1 screen. Cannot have more.
Can change video/attr/dl address freely and it will be remembered on next VT switch.

## Memory management

The rest (223) of memory banks (32-254) are free to use for applications.
The task wanting to assume a bank, can request a free bank from OS and be given a number of bank to use exclusively, or 255 (-1) on failure (no more free banks).
The application then can store data (using data bank register) or code (for use by program bank register) in given bank.
It is up to the application to track its own task-id and given data banks numbers. The OS does not provide bookkeeping. Good idea may be to use some global variables in task's direct page.

## Device naming

- one letter codes for the device
- with possible digit subcode

Internally devices are coded with a non-zero byte, and subdevice is coded with one byte major,minor style
Devices 0 and 255 are reserved and invalid.
Subdevice 0 is default and can be omitted.
User-usable devices are coded with uppercase ASCII letters:
- `D` - (disk) drive - with numbered subdevice same as in `0:` `1:` etc. USB drives in system monitor
- `E` - editor - subdevice is VT
- `K` - keyboard?
- `P` - printer - subdevice is connected printer number
- `S` - screen - subdevice is VT
- `R` - ramdrive? random?
- `N` - null

- http://atariki.krap.pl/index.php/CIO
- http://atariki.krap.pl/index.php/Lista_handler%C3%B3w_CIO

There is also an "assign" allowing to map non-used letters to specific device.
Default: `A:` -> `D0:`, `B:` -> `D1:`

## Timers

Monotonic time is measured by OS with a granularity of 1/60 sec. by VBL in a 32bit counter. (wraps after 828,5 days).

TOD is provided by RIA

