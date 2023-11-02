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