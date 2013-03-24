(* Simple demo program showing how to receive domain events.
   Usage: domain_events [URI]
   (C) Copyright 2007 Richard W.M. Jones, Red Hat Inc.
   (C) Copyright 2013 Citrix Inc
   http://libvirt.org/
 *)

open Printf

module C = Libvirt.Connect
module D = Libvirt.Domain
module DE = Libvirt.DomainEvent
module N = Libvirt.Network

let string_of_state = function
  | D.InfoNoState -> "no state"
  | D.InfoRunning -> "running"
  | D.InfoBlocked -> "blocked"
  | D.InfoPaused -> "paused"
  | D.InfoShutdown -> "shutdown"
  | D.InfoShutoff -> "shutoff"
  | D.InfoCrashed -> "crashed"

let print_dom dom =
  fprintf stderr "callback\n%!";
  let id = D.get_id dom in
  try
    let name = D.get_name dom in
    let info = D.get_info dom in
    let state = string_of_state info.D.state in
    printf "%8d %-20s %s\n%!" id name state
  with _ ->
    printf "%8d\n%!" id

let () =
  try
    DE.register_default_impl ();
    let name =
      if Array.length Sys.argv >= 2 then
	Some (Sys.argv.(1))
      else
	None in
    let conn = C.connect_readonly ?name () in

    DE.register_any conn (DE.Lifecycle (fun dom (event, detail) -> print_dom dom));
(*
    DE.register_any conn (DE.Reboot print_dom);
    DE.register_any conn (DE.RtcChange print_dom);
    DE.register_any conn (DE.Watchdog print_dom);
    DE.register_any conn (DE.IOError print_dom);
    DE.register_any conn (DE.Graphics print_dom);
    DE.register_any conn (DE.IOErrorReason print_dom);
    DE.register_any conn (DE.ControlError print_dom);
    DE.register_any conn (DE.BlockJob print_dom);
    DE.register_any conn (DE.DiskChange print_dom);
    DE.register_any conn (DE.TrayChange print_dom);
    DE.register_any conn (DE.PMWakeUp print_dom);
    DE.register_any conn (DE.PMSuspend print_dom);
    DE.register_any conn (DE.BalloonChange print_dom);
    DE.register_any conn (DE.PMSuspendDisk print_dom);
*)
    C.set_keep_alive conn 5 3;
    while true do
        fprintf stderr "run_default_impl\n%!";
	DE.run_default_impl ()
    done
  with
    Libvirt.Virterror err ->
      eprintf "error: %s\n" (Libvirt.Virterror.to_string err)

let () =
  (* Run the garbage collector which is a good way to check for
   * memory corruption errors and reference counting issues in libvirt.
   *)
  Gc.compact ()
