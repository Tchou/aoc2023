open Utils
module S =
struct
  let name = Name.mk "s21"

  let output_string queue s =
    String.iter (fun c -> Queue.push (Char.code c) queue) s

  let display_collect queue =
    let rec loop acc =
      if Queue.is_empty queue then acc else
        let n = Queue.pop queue in
        if n > 255 then loop (n::acc)
        else begin
          Format.printf "%c%!" (Char.chr n);
          loop acc
        end
    in loop [] |> List.rev

  (* Brute force ! 

      1010 ->  D&~C&B&~A
  *)

  (*  let compile letters n =
      let open Format in
      let rec loop i n acc =
        if i >= String.length letters then 
          acc |> List.rev |> String.concat ""
        else
          let acc =
          if n land 1 = 0 then sprintf "OR %c J\n" letters.[i]
          else *)
  let advance code txt =
    let state = Intcode.make_state code in
    let c = Intcode.eval state in
    assert (c = `need_input);
    output_string state.stdin txt;
    let c = Intcode.eval state in
    assert (c = `halt);
    display_collect state.stdout

  let walk = "\
NOT C J\n\
AND D J\n\
NOT A T\n\
OR T J\n\
WALK\n"

  let solve txt =
    let code = Intcode.read () in
    let n = advance code txt |> List.hd in
    Ansi.(printf "%a%d%a\n" fg green n clear color)

  let solve_part1 () = solve walk

  (* Start with part 1 and add bits by bits… *)
  let run = "\
NOT C T\n\
NOT B J\n\
OR T J\n\
NOT A T\n\
OR T J\n\
OR E T\n\
OR H T\n\
AND D T\n\
AND T J\n\
RUN\n"
  let solve_part2 () = solve run
end
(* D & !(E | G) *)
let () = Solution.register_mod (module S)