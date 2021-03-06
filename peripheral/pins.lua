--- 模块功能：GPIO 功能配置，包括输入输出IO和上升下降沿中断IO
-- @module pins
-- @author openLuat
-- @license MIT
-- @copyright openLuat
-- @release 2017.09.23 11:34
require "sys"
module(..., package.seeall)
local interruptCallbacks = {}
local dirs = {}
--- 配置GPIO模式
-- @number pin，GPIO ID
-- GPIO 0到GPIO 31表示为pio.P0_0到pio.P0_31
-- GPIO 32到GPIO XX表示为pio.P1_0到pio.P1_(XX-32)，例如GPIO33 表示为pio.P1_1
-- GPIO 64到GPIO XX表示为pio.P2_0到pio.P2_(XX-64)，例如GPIO65 表示为pio.P2_1
-- @param val，number、nil或者function类型
-- 配置为输出模式时，为number类型，表示默认电平，0是低电平，1是高电平
-- 配置为输入模式时，为nil
-- 配置为中断模式时，为function类型，表示中断处理函数
-- @param pull, number, pio.PULLUP：上拉模式 。pio.PULLDOWN：下拉模式。pio.NOPULL：高阻态
-- 如果没有设置此参数，默认的上下拉参考模块的硬件设计说明书
-- @return function
-- 配置为输出模式时，返回的函数，可以设置IO的电平
-- 配置为输入或者中断模式时，返回的函数，可以实时获取IO的电平
-- @usage setOutputFnc = pins.setup(pio.P1_1,0)，配置GPIO 33，输出模式，默认输出低电平；
--执行setOutputFnc(0)可输出低电平，执行setOutputFnc(1)可输出高电平
-- @usage getInputFnc = pins.setup(pio.P1_1,intFnc)，配置GPIO33，中断模式
-- 产生中断时自动调用intFnc(msg)函数：上升沿中断时：msg为cpu.INT_GPIO_POSEDGE；下降沿中断时：msg为cpu.INT_GPIO_NEGEDGE
-- 执行getInputFnc()即可获得当前电平；如果是低电平，getInputFnc()返回0；如果是高电平，getInputFnc()返回1
-- @usage getInputFnc = pins.setup(pio.P1_1),配置GPIO33，输入模式
--执行getInputFnc()即可获得当前电平；如果是低电平，getInputFnc()返回0；如果是高电平，getInputFnc()返回1

local function netled(pin)

end

function setup(pin, val, pull)
    return netled
end

--- 关闭GPIO模式
-- @number pin，GPIO ID
--
-- GPIO 0到GPIO 31表示为pio.P0_0到pio.P0_31
--
-- GPIO 32到GPIO XX表示为pio.P1_0到pio.P1_(XX-32)，例如GPIO33 表示为pio.P1_1
-- @usage pins.close(pio.P1_1)，关闭GPIO33
function close(pin)

end

rtos.on(rtos.MSG_INT, function(msg)
    if interruptCallbacks[msg.int_resnum] == nil then
        log.warn('pins.rtos.on', 'warning:rtos.MSG_INT callback nil', msg.int_resnum)
    end
    interruptCallbacks[msg.int_resnum](msg.int_id)
end)
