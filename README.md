# UVM Verification of 4-bit Multiplier

## Overview

This project demonstrates the verification of a **4-bit Multiplier** using the **Universal Verification Methodology (UVM)**. The goal is to ensure the functionality of a simple 4-bit **Multiplier** circuit.


## Running the Code

To run the UVM code examples in this repository, you can use **EDA Playground**, an online simulation platform. Follow these steps to get started:

1. **Visit EDA Playground:**
   Open your browser and go to [EDA Playground](https://www.edaplayground.com).

2. **Configure Your Environment:**
   - On the left side of the page, find the **UVM** option and set it to **1.2**.
   - Set **Tools & Simulators** to **Aldec Riviera Pro 2023.04**.

3. **Run the Simulation:**
   After the configuration, simply click on the **Run** button to start the simulation.

The code will execute on the platform, and you can view the simulation results in the output section.

## Stages

1. **Transaction:** Keep track of all the I/O present in DUT(uvm_sequence_item)
2. **Sequence:** combination of transactions to verify specific test case(uvm_sequence)
3. **sequencer:** Manage sequences. send sequence to driver after request (uvm_sequencer)
4. **Driver:** send request to driver for sequence, apply sequence to the DUT (uvm_driver)
5. **Monitor:** collect response of DUT and forward to scoreboard (uvm_monitor)
6. **Scoreboard:** compare response with golden data (uvm_scoreboard)
7. **Agent:** Encapsulate Driver, sequencer, monitor. connection of driver sequencer TLM ports (uvm_agent)
8. **Env:** Encapsulate agent and scoreboard. connection of analysis port of Monitor and scoreboard (uvm_env)
9. **Test:** Encapsulate Env, start sequence (uvm_test)