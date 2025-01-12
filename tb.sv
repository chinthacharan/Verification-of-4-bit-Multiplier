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
            seq_item_port.item_done(tr);
            `uvm_info("DRV", $sformatf("Sequence applied to DUT a: %0d, b: %0d, y: %0d", tr.a, tr.b, tr.y));
        end
    endtask
endclass