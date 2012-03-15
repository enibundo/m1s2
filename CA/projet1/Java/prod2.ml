
open Types;;
open Typeur;;
open Env_typeur;;
open Env_trans;;
open Langinter;;

(* des symboles globaux bien utiles par la suite *)

let compiler_name = ref "ml2python";;
let object_suffix = ref ".py";;

let prod_fun instr = match instr with
    FUNCTION (ns, t1, ar, (lp, t2), instr) ->
      let fun_name = "MLfun_"^ns in 
	begin
	  out_line ("def "^fun_name^":");
	  out_line ("
	end;
