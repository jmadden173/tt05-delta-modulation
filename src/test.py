import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


@cocotb.test()
async def test_reset(dut):
    """Checks that outputs are zero'd when inputs are zero'd and the chip is
    reset.
    """
    
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # reset
    dut._log.info("reset")
    dut.rst_n.value = 0 
    await ClockCycles(dut.clk, 10)

    # zero inputs
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 1
    
    await ClockCycles(dut.clk, 10)

    assert int(dut.spike.value) == 0
    assert int(dut.prev.value) == 0


@cocotb.test()
async def test_basic(dut):
    """Tests that spikes are generated when a threshold is exceeded."""
    
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # reset
    dut._log.info("reset")
    dut.rst_n.value = 0 
    await ClockCycles(dut.clk, 10)

    # zero inputs
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 1 
    await ClockCycles(dut.clk, 10)

    # sequence of inputs
    data_list = [1, 2, 5, 5, 5]
    spike_list = [0, 0, 0, 1, 0]

    # create prev list two cycles later 
    prev_list = [0, 0] + data_list[:-2]
    
    dut.threshold.value = 2

    for data, prev, spike in zip(data_list, prev_list, spike_list):
        dut.data.value = data
        await ClockCycles(dut.clk, 1)

        #dut._log.info(f"data: {dut.data.value}, prev: {dut.prev.value}")
        #dut._log.info(f"data: {data}, prev: {prev}")

        assert int(dut.spike.value) == spike
        assert int(dut.prev.value) == prev

    await ClockCycles(dut.clk, 10)