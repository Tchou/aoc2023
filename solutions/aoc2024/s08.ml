open Utils
open Syntax
module S =
struct
  let name = Name.mk "s08"
  module G = Grid.StringGrid

  let count_antinodes resonnance grid =
    let h = G.height grid in
    let w = G.width grid in
    let rmin, rmax = if resonnance then 0, max h w else 1, 1 in
    let map = ~%[] in
    G.iter (fun pos c ->
        if c <> '.' then map.%{c} <- pos::(map.%?{c} or [])
      ) grid;
    let unique_pos = ~%[] in
    map
    |> Hashtbl.iter (fun _ coords ->
        coords
        |> Comb.pairs ~sym:false ~refl:false
        |> Seq.iter (fun ((x1, y1),(x2, y2)) ->
            for r = rmin to rmax do
              let dx = x2 - x1 in
              let dy = y2 - y1 in
              let p1 = (x1 - r * dx, y1 - r * dy) in
              let p2 = (x2 + r * dx, y2 + r * dy) in
              if G.inside grid p1 then unique_pos.%{p1} <- ();
              if G.inside grid p2 then unique_pos.%{p2} <- ();
            done
          ));
    Hashtbl.length unique_pos
  let solve resonnance =
    let grid = G.read() in
    let n = count_antinodes resonnance grid in
    Solution.printf "%d" n

  let solve_part1 () = solve false
  let solve_part2 () = solve true
end

let () = Solution.register_mod (module S)