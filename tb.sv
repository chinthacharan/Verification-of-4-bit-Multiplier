`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;

    rand bit [3:0] a;
    rand bit [3:0] b;
         bit [7:0] y;
    
    
    function new(input string path = "transaction");
        super.new(path);
    endfunction

    `uvm_object_utils_begin(transaction)
         `uvm_field_int(a, UVM_DEFAULT)
         `uvm_field_int(b, UVM_DEFAULT)
         `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end

endclass

class generator extends uvm_sequence#(transaction);
    `uvm_object_utils(generator)

    function new(string path = "generator");
        super.new(path);
    endfunction

    transaction tr;

    virtual task body();
        repeat(15) begin
            tr = transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize());
            finish_item(t);
            `uvm_info("GEN", $sformat("Data sent to driver a: %0d, b: %0d, y: %0d", tr.a, tr.b, tr.y));
        end
    endtask
endclass

class driver extends uvm_driver#(transaction);
    `uvm_component_utils(driver)

    transaction tr;
    virtual mul_if mif;

    function new(string path = "driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = transaction::type_id::create("tr");
        if(!uvm_config_db #(virtual mul_if)::get(this,"", "aif", aif)) //uvm_test_top.env.agnet.driver.aif
        `uvm_error("DRV", "Unable to access the interface");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);
            `uvm_info("DRV", "Driver started", UVM_NONE);
            mif.a <= tr.a;
            mif.b <= tr.b;
            mif.y <= tr.y;
            seq_item_port.item_done();
            #20;
            `uvm_info("DRV", $sformatf("Sequence applied to DUT a: %0d, b: %0d, y: %0d", tr.a, tr.b, tr.y), UVM_NONE);
        end
    endtask
endclass

class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    function new(string path = "monitor", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    transaction tr;
    virtual mul_if mif;
    uvm_analysis_port #(transaction) send;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = transaction::type_id::create("t");
        send = new("send", this);
        if(!uvm_config_db #(virtual mul_if)::get(this, "", "mif", mif), UVM_NONE);
        `uvm_error("MON", "Unable to access interface");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            #20; //since we provided this amount of delay in driver
            tr.a = mif.a;
            tr.b = mif.b;
            tr.y = mif.y;
            `uvm_info("MON", $sformat("Data received from DUT a: %0d, b:%0d, y:%0d", tr.a, tr.b, tr.y), UVM_NONE);
            send.write(tr);
        end
    endtask
endclass

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    function new(string path = "scoreboard", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    uvm_sequence_imp #(transaction, scoreboard) recv;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv = new("recv", this);
    endfunction

    virtual task write(transaction tr);
        if(tr.y == (tr.a * tr.b))
            `uvm_info("SCO", $sformatf("Test Passed -> a: %0d, b:%0d, c:%0d", tr.a, tr.b, tr.y), UVM_NONE);
        else begin
            `uvm_error("SCO", "test faield");
        end
    endtask
endclass

class agent extends uvm_agent;
    `uvm_component_utils(agent)

    function new(string path = "agent", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    uvm_sequencer #(transaction) seqr;
    driver d;
    monitor m;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seqr = uvm_sequencer #(transaction)::type_id::create("seqr", this);
        d = driver::type_id::create("d", this);
        m = monitor::type_id::create("m", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d.seq_item_port.connect(seqr.seq_item_export);
    endfunction

endclass

class env extends uvm_env;
    `uvm_component_utils(env)

    function new(string path = "env", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    agent a;
    scoreboard s;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a = agent::type_id::create("a", this)
        s = scoreboard::type_id::create("s", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a.m.send.connect(s.recv);
    endfunction

endclass

class test extends uvm_test;
    `uvm_component_utils(test)

    function new(string path = "test", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    env e;
    generator gen;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e = env::type_id::create("e", this);
        gen = generator::type_id::create("gen");
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        gen.start(e.a.seqr);
        #20;
        phase.drop_objection(this);
    endtask
endclass

module tb;
    mul_if mif();
    mul dut (.a(mif.a), .b(mif.b), .y(mif.y));
    initial begin
        uvm_config_db #(transaction)::set(null,"*", "mif", mif);
        run_test("test");
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
endmodule

    



