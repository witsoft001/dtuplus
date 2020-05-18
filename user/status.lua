require "lnxall_conf"

status={}

local nodes_status={}
local last_report = os.time()

function status.reload()
    nodes_status={}
end

local function check_symbol(sn)
    if not sn then return nil end
    if not nodes_status[sn] then nodes_status[sn] = {}  end
    if not nodes_status[sn].rx_cnt then nodes_status[sn].rx_cnt = 0  end
    if not nodes_status[sn].tx_cnt then nodes_status[sn].tx_cnt = 0  end
    if not nodes_status[sn].resp_cnt then nodes_status[sn].resp_cnt = 0  end
    if not nodes_status[sn].last_rcv then nodes_status[sn].last_rcv = 0  end
    if not nodes_status[sn].sn then nodes_status[sn].sn = sn  end
    if not nodes_status[sn].loss_ratio 	 then nodes_status[sn].loss_ratio 	 = nil  end
    if not nodes_status[sn].online then nodes_status[sn].online = nil  end
    if not nodes_status[sn].last_online then nodes_status[sn].last_online = nil  end


    -- if not nodes_status[sn].rx_cnt then nodes_status[sn].rx_cnt = 0  end
    -- if not nodes_status[sn].tx_cnt then nodes_status[sn].tx_cnt = 0  end
    -- if not nodes_status[sn].resp_cnt then nodes_status[sn].resp_cnt = 0  end
    -- if not nodes_status[sn].last_rcv then nodes_status[sn].last_rcv = 0  end
    -- if not nodes_status[sn].sn then nodes_status[sn].sn = sn  end
    -- if not nodes_status[sn].loss_ratio 	 then nodes_status[sn].loss_ratio 	 = nil  end
    -- if not nodes_status[sn].online then nodes_status[sn].online = nil  end
    -- if not nodes_status[sn].last_online then nodes_status[sn].last_online = nil  end
    return true
end

function status.tx_add(sn)
    if check_symbol(sn) then
        nodes_status[sn].tx_cnt = nodes_status[sn].tx_cnt + 1
    end
end

function status.rx_add(sn)
    if check_symbol(sn) then
        nodes_status[sn].rx_cnt = nodes_status[sn].rx_cnt + 1
        nodes_status[sn].last_rcv = os.time()
    end
end

function status.resp_add(sn)
    if check_symbol(sn) then
        nodes_status[sn].resp_cnt = nodes_status[sn].resp_cnt + 1
        nodes_status[sn].last_rcv = os.time()
    end
end

sys.timerLoopStart(function()
    local change = false
    for sn,status in pairs(nodes_status) do
        local offtime = lnxall_conf.offlineTimeBysn(sn)
        if status.last_rcv and offtime and os.time() < (status.last_rcv + offtime) then
            status.online = true
        else
            status.online = false
        end
        --
        if status.tx_cnt and status.tx_cnt == 0 then status.loss_ratio 	 = 0
        else status.loss_ratio 	 = (status.tx_cnt - status.resp_cnt) * 100 / status.tx_cnt
        end

        -- 判断是否离线标记
        if status.online ~= status.last_online then
            status.last_online = status.online
            change = true
        end
    end

    if change or os.difftime(os.time(),last_report) >= 3600 then
        last_report = os.time()
        local report = {}
        report.nodes_status={}
        for sn,status in pairs(nodes_status) do
            table.insert(report.nodes_status,status)
            -- 去掉不用的变量
            report.nodes_status.last_online = nil
            report.nodes_status.resp_cnt = nil
        end

        local str =  json.encode(report)
        if str then
            sys.publish("JJ_NET_SEND_MSG_" .. "NodesStatus", str)
        end
    end
end, 10 * 1000)

return status