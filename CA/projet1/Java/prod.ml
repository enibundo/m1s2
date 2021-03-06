(************************************************************************
 *                                                                      *
 *                       MASTER STL M1 anne'e 2005/06                   *
 *                                                                      *
 *                     Cours Compilation Avanceels                      *
 *                                                                      *
 *                       Compilation -> Langage intermediaire           *
 *                                                                      *
 *                         partie de ml2java                            *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 *   prodjava.ml  : traducteur LI_instr -> texte Java                   *
 *                                                                      *
 *   version : 0.1           12/04/06                                   *
 *                                                                      *
 *   auteur : Emmanuel Chailloux                                        *
 *                                                                      *
 ************************************************************************)

open Types;;
open Typeur;;
open Env_typeur;;
open Env_trans;;
open Langinter;;


(* des symboles globaux bien utiles par la suite *)

let compiler_name = ref "ml2java";;
let object_suffix = ref ".py";;

(* des valeurs pour certains symboles de env_trans *)

pair_symbol:=",";;
cons_symbol:="::";;
ref_symbol:="ref";;

(* l'environnement initial du traducteur en liaison avec la Runtime *)

let build (s,equiv)  = 
  let t = 
      try List.assoc s !initial_typing_env  
      with Not_found -> 
        failwith ("building initial_trans_env : for symbol : "^s)
  in (s,(equiv,type_instance t));;

(*
let get_param_type fun_t =  match fun_t with 
  Fun_type (Pair_type (t1,t2),tr) -> [t1;t2],tr
| Fun_type ( t1,tr) -> [t1],tr
| _ -> failwith "get_param_type"
;;
*)

initial_special_env := 
 List.map build [
      "hd","MLfun_hd";
      "tl","MLfun_tl";
      "fst","MLfun_fst";
      "snd","MLfun_snd"
];;


initial_trans_env:= 

let alpha = max_unknown () in
[",",("MLruntime.MLpair", Fun_type (Pair_type (alpha,alpha),
                                    Pair_type (alpha,alpha)))]@
["::",("MLruntime.MLlist", Fun_type (Pair_type (alpha,alpha),
                                    List_type (alpha)))]@

(
List.map build 
     ["true" ,"True"; (* maybe operator.truth() *)
      "false","False";
      "+", "operator.add";
      "-", "operator.sub";
      "*", "operator.mul";
      "/", "opeartor.div";
      "=", "operator.eq";
      "<", "operator.lt";
      "<=","opeartor.le";
      ">", "operator.gt";
      ">=","operator.ge";
      "^", "operator.concat"
      
]
)
;;

(* des fonctions d'I/O *)

let output_channel = ref stdout;;
let change_output_channel oc = output_channel := oc;;

let shift_string = String.make 256 '\t';;
let out s = output_string !output_channel s;;


(*let out_start s nb = out ("\n"^(String.sub shift_string 0 (2*nb))^s);;
*)

let out_start s nb = 
  out ("\n"^(String.sub shift_string 0 nb)^s^"");;

let out_end s nb = 
  out ("\n"^(String.sub shift_string 0 nb)^"\n");;

let out_line s = out (s^"\n");;

let out_before (fr,sd,nb) = 
  if sd<>"" then out_start (sd^"=") nb
  else if fr then out_start ("return ") nb;;


let out_after  (fr,sd,nb) = 
  if sd<>"" then 
  begin
      out ";";
      if fr then out (("return "^sd^";"))
  end
  else if fr then out ";";;


(* des fonctions utilitaires pour commenter un peu la production *)

let header_main  s = 
  List.iter out 
    ["import operator\n";
     "import functools\n";
     "#\n";
     "MLfun_hd=lambda x:x[0]\n";
     "MLfun_tl=lambda x:x[1:]\n";
     "MLfun_fst = MLfun_hd\n";
     "MLfun_snd = lambda x:MLfun_tl(x)[0]\n"
    ]
;;

let footer_main  s = 
  List.iter out
   ["// fin du fichier " ^ s ^ ".java\n"]
;;

let header_one  s = 
   List.iter out
     [];;


let footer_one  s = ();;

let header_two  s = 
  List.iter out
  [ "##\n";
    "#  \n";
    "# \n";
  ]
;;

let footer_two  s = ();;

let header_three  s = 
  List.iter out
    []
;;

let footer_three  s = 
  List.iter out
  [ ]
;;

let string_of_const_type ct = match ct with   
    _->""
;;
 
let rec string_of_type typ = match typ with 
    _ -> ""
;;


let prod_global_var instr = match instr with
| FUNCTION (ns,t1,ar,(p,t2), instr) ->
    out (ns^"= MLfun_"^ns);
    out_start "" 1
| _ -> ()
;;

let prod_two  ast_li = 
  List.iter prod_global_var ast_li
;;

let get_param_type lv = 
  List.map (function (VAR(name,typ)) -> typ 
              | _ -> failwith "get_param_type" ) lv;;


let prod_const c = match c with 
    INT i -> out (string_of_int i)
  | FLOAT f -> out (string_of_float f)
  | BOOL b  -> out (if b then "True" else "False")
  | STRING s -> out ("\""^s^"\"")
  | EMPTYLIST -> out ("[]")
  | UNIT ->      out ("None")
;;

let rec prod_local_var (fr,sd,nb) (v,t) =
  ()
;;

let rec prod_instr (fr,sd,nb) instr  = match instr with 
    CONST c -> out_before (fr,sd,nb);
      prod_const c;
      out_after (fr,sd,nb)
  | VAR (v,t)
    ->
      if (nb = 0) && ( sd = "") then ()
      else 
        begin 
	  out_before (fr,sd,nb);
          out v;
          out_after (fr,sd,nb)      
        end
  | IF(i1,i2,i3) ->
      out_start "if (" nb;
      prod_instr (false,"",nb) i1 ;
      out "):";
      prod_instr (fr,sd,nb+1) i2 ;
      out_start "else:" (nb);
      prod_instr (fr,sd,nb+1) i3
  | RETURN i -> prod_instr (true,"",nb) i
  | AFFECT (v,i) -> prod_instr (false,v,nb) i
  | BLOCK(l,i) -> 
      List.iter (fun (v,t,i) -> prod_instr (false,v,nb) i) l;
      prod_instr (fr,sd,nb) i;
      
	
  | APPLY(i1,i2) -> 
      out_before(fr,sd,nb);
      
      prod_instr (false,"",nb) i1;
      
      out"(";
      prod_instr (false,"",nb) i2;     
      out")";
      out_after(fr,sd,nb)
  | PRIM ((name,typ),instrl) ->
      let ltp = get_param_type instrl in 
	out_before (fr,sd,nb);
	out (name^"( ");
	prod_instr (false,"",nb+1) (List.hd instrl);
	List.iter2 (fun x y -> out (",");
                      prod_instr (false,"",nb+1) x) 
	  (List.tl instrl) (List.tl ltp);
	out ")" ;
	out_after(fr,sd,nb)              
  | FUNCTION _ -> ()
;;

let fun_header fn cn  = ()
;;

let prod_invoke cn  ar = () ;;

let prod_invoke_fun cn ar t lp instr = 
  out ("def "^cn^"(");
  out (List.hd lp);
  List.iter (fun x -> out (", "^x)) (List.tl lp);
  out "):";
  prod_instr (true,"",1) instr;
;;


(*
 ar - arity
 ns - namespace (name of function)
 lp - liste parametres
*)
let prod_fun instr = match instr with 
  FUNCTION (ns,t1,ar,(lp,t2),instr) -> 
    let class_name = "MLfun_"^ns in
      fun_header ns class_name ;
      prod_invoke_fun class_name ar t1 lp instr;
      out_line "";
  |  _ -> ()
;;


let prod_one  ast_li = 
  List.iter prod_fun ast_li
;;




let prod_three  ast_li = 
 List.iter (prod_instr  (false,"",0) ) ast_li
;;



let prod_file filename ast_li = 
  let obj_name = filename ^ !object_suffix in 
  let oc = open_out obj_name in 
  change_output_channel oc;  
  module_name:=filename;
  try 
   
    header_main  filename;

    header_one  filename;
    prod_one  ast_li;
    footer_one  filename;
    header_two  filename;
    prod_two  ast_li;
    footer_two  filename;
    (*header_three  filename;*)
    prod_three  ast_li;
    (*footer_three  filename;*)
    footer_main  filename;
    close_out oc
  with x -> close_out oc; raise x;;



