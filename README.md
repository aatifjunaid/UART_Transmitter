  # UART Transmitter using Verilog HDL

## Overview

This project implements an 8-bit UART (Universal Asynchronous Receiver Transmitter) Transmitter in Verilog HDL. The design uses a Finite State Machine (FSM) to control serial data transmission and includes a custom Verilog testbench for functional verification through simulation.

The transmitter follows the standard UART frame format consisting of:
- 1 Start Bit
- 8 Data Bits (LSB First)
- 1 Stop Bit

---

## Features

- Verilog HDL implementation
- FSM-based control logic
- 8-bit serial data transmission
- Configurable baud rate using a parameter
- Shift-register based serialization
- Busy and Done status signals
- Custom Verilog testbench
- Simulation waveform verification

---

## Project Structure

```
UART-Transmitter/
│── uart_tx.v          // UART Transmitter RTL
│── uart_tx_tb.v       // Testbench
│── README.md
│── images/
│     └── waveform.png
```

---

## Finite State Machine (FSM)

The UART transmitter operates using four states:

```
        +------+
        | IDLE |
        +------+
            |
            | tx_start
            v
        +-------+
        | START |
        +-------+
            |
            v
        +------+
        | DATA |
        +------+
            |
            v
        +------+
        | STOP |
        +------+
            |
            +------------+
                         |
                         v
                      IDLE
```

---

## Inputs

| Signal | Description |
|--------|-------------|
| `clk` | System Clock |
| `reset` | Asynchronous Reset |
| `tx_start` | Starts a transmission |
| `tx_data[7:0]` | 8-bit input data |

---

## Outputs

| Signal | Description |
|--------|-------------|
| `tx` | Serial UART output |
| `busy` | High while transmission is in progress |
| `done` | Pulses high when transmission completes |

---

## Simulation

The design was verified using a custom Verilog testbench.

The following data bytes were transmitted during simulation:

- 0x55
- 0xA5
- 0xFF

The generated waveform verified:

- Correct Start Bit generation
- LSB-first serial transmission
- Correct Stop Bit generation
- Proper FSM state transitions
- Busy and Done signal operation

---

## Waveform

<img width="952" height="317" alt="Screenshot 2026-10-14 102004" src="https://github.com/user-attachments/assets/f861e18c-4638-41b2-9767-590cc5c05703" />

<img width="949" height="349" alt="Screenshot 2026-10-14 102022" src="https://github.com/user-attachments/assets/cd0f834f-7da5-476c-96f7-c8b93795d003" />





```
images/waveform.png
```

---

## Tools Used

- Verilog HDL
- EDA Playground
- EPWave

---

## Future Improvements

- UART Receiver implementation
- Parity bit support
- Configurable stop bits
- Parameterized data width
- SystemVerilog-based verification

---

## Author

**Aatif Junaid**
