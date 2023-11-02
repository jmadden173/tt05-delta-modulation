from typing import Mapping, List

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


async def reset_dut(clk, rst_n, ui_in, uio_in, cycles=10) -> None:
    """Resets test to known state

    The reset input is triggered, inputs are zero, then waits for cycles to pass

    Args:
        rst_n : Reset input
        ui_in : Universal input
        uio_in : Universal IO input
        cycles (int, optional) : number of cycles to wait between triggering resets
    """
    
    # reset
    rst_n.value = 0 
    await ClockCycles(clk, 10)

    # zero inputs
    ui_in.value = 0
    uio_in.value = 0
    rst_n.value = 1
    
    await ClockCycles(clk, 10)

    rst_n._log.info("Reset")


async def check_sequence(
        clk,
        data,
        spike,
        prev,
        threshold,
        seq: Mapping[str, List[int] | int],
        cycles: int = 1
    ) -> None:
    """bla"""

    # set threshold
    threshold.value = 2

    # create prev list two cycles later 
    seq["prev"] = [0, 0] + seq["data"][:-2]

    for d, p, s in zip(seq["data"], seq["prev"], seq["spikes"]):
        data.value = d
        await ClockCycles(clk, 1)

        #dut._log.info(f"data: {dut.data.value}, prev: {dut.prev.value}")
        #dut._log.info(f"data: {data}, prev: {prev}")

        assert int(prev.value) == p
        assert int(spike.value) == s


@cocotb.test()
async def test_reset(dut):
    """Checks that outputs are zero'd when inputs are zero'd and the chip is
    reset.
    """
    
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut.clk, dut.rst_n, dut.ui_in, dut.uio_in)

    assert int(dut.spike.value) == 0
    assert int(dut.prev.value) == 0


@cocotb.test()
async def test_basic(dut):
    """Tests that spikes are generated when a threshold is exceeded."""
    
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # reset
    await reset_dut(dut.clk, dut.rst_n, dut.ui_in, dut.uio_in)

    sequence_list = {
        "single spike" : {
            "data": [1, 2, 5, 5, 5],
            "spikes": [0, 0, 0, 1, 0],
            "threshold": 2
        },
        "multiple concurrent spikes" : {
            "data": [1, 4, 7, 10, 7, 4, 1, 0],
            "spikes": [0, 0, 1, 1, 1, 0, 0, 0],
            "threshold": 2
        },
        "multiple independent spikes" : {
            "data": [0, 3, 0, 3, 0, 3, 0],
            "spikes": [0, 0, 1, 0, 1, 0, 1],
            "threshold": 2
        }
    }

    for name, seq in sequence_list.items():
        dut._log.info(f"Testing {name} sequence")
        await check_sequence(dut.clk, dut.data, dut.spike, dut.prev, dut.threshold, seq)
        await ClockCycles(dut.clk, 10)
        await reset_dut(dut.clk, dut.rst_n, dut.ui_in, dut.uio_in)