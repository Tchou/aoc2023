open Utils

let has_char s c =
  match String.index s c with _ -> true | exception Not_found -> false

let load_level () =
  let a = ref [||] in
  let ensure s =
    let l = String.length s + 1 in
    assert (l mod 4 = 0);
    let la = Array.length !a in
    if la = 0 then a := Array.make (l / 4) [] else assert (la = l / 4)
  in
  let rec loop () =
    match Input.read_line () with
    | "" -> Array.map List.rev !a
    | s when String.mem '[' s ->
        ensure s;
        for i = 0 to Array.length !a - 1 do
          let c = s.[(4 * i) + 1] in
          if c <> ' ' then !a.(i) <- c :: !a.(i)
        done;
        loop ()
    | s -> ensure s; loop ()
  in
  loop ()

let move a i j =
  match a.(i) with
  | e :: l ->
      a.(i) <- l;
      a.(j) <- e :: a.(j)
  | _ -> assert false

let move_9000 a i j n =
  for _ = 0 to n - 1 do
    move a i j
  done

let print_array fmt a =
  let sa =
    Array.map (fun l -> String.concat "" (List.map (String.make 1) l)) a
  in
  let max_l = ref 0 in
  Array.iter (fun s -> max_l := max !max_l (String.length s)) sa;
  Array.iteri
    (fun i s ->
      let pref = String.make (!max_l - String.length s) ' ' in
      sa.(i) <- pref ^ s)
    sa;
  for i = 0 to !max_l - 1 do
    for j = 0 to Array.length sa - 1 do
      let c = sa.(j).[i] in
      if c = ' ' then Format.fprintf fmt "    "
      else Format.fprintf fmt "[%c] " c
    done;
    Format.fprintf fmt "\n"
  done;
  for j = 1 to Array.length sa do
    Format.fprintf fmt "% 2d  " j
  done;
  Format.fprintf fmt "\n"

let debug a s =
  let open Ansi in
  printf "%a%!" clear screen;
  printf "%s@\n" s;
  printf "%a@\n" print_array a;
  Unix.sleepf 0.5

let solve ?(animate = false) do_n_move () =
  let a = load_level () in
  let () = if animate then debug a "" in
  a
  |> Input.fold_fields ' ' (fun a -> function
       | [ "move"; sn; "from"; si; "to"; sj ] as order ->
           let n = int_of_string sn in
           let i = int_of_string si in
           let j = int_of_string sj in
           do_n_move a (i - 1) (j - 1) n;
           if animate then debug a (String.concat " " order);
           a
       | _ -> a)
  |> Array.map (function c :: _ -> String.make 1 c | _ -> "")
  |> Array.to_list |> String.concat "" |> Solution.printf "%s"

let split_n l n =
  let rec loop n l acc =
    if n = 0 then acc, l
    else
      match l with p :: ll -> loop (n - 1) ll (p :: acc) | _ -> assert false
  in
  loop n l []

let move_9001 a i j n =
  let to_move, staying = split_n a.(i) n in
  let dest = List.rev_append to_move a.(j) in
  a.(i) <- staying; a.(j) <- dest

module Sol = struct
  let name = Name.mk "s05"
  let solve_part1 = solve move_9000
  let solve_part2 = solve move_9001
end

module SolA = struct
  let name = Name.mk "s05"
  let solve_part1 = solve ~animate:true move_9000
  let solve_part2 = solve ~animate:true move_9001
end

let () =
  Solution.register_mod (module Sol);
  Solution.register_mod ~variant:"animate" (module SolA)
