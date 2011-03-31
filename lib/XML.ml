(* $Id: xML.ml,v 1.14 2004/12/13 14:57:45 ohl Exp $

   Copyright (C) 2004 by Thorsten Ohl <ohl@physik.uni-wuerzburg.de>

   XHTML is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   XHTML is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  *)

(** Attributes *)

type separator = Space | Comma

type aname = string
type acontent =
  | AFloat of aname * float (* Cecile *)
  | AInt of aname * int
  | AStr of aname * string
  | AStrL of separator * aname * string list
type attrib = acontent
type event = string

let acontent a = a
let aname a = match a with
| (AFloat (name, _) | AInt (name, _) | AStr (name, _) | AStrL (_, name, _)) -> name

let float_attrib name value = AFloat (name, value) (* Cecile *)
let int_attrib name value = AInt (name, value)
let string_attrib name value = AStr (name, value)
let space_sep_attrib name values = AStrL (Space, name, values)
let comma_sep_attrib name values = AStrL (Comma, name, values)
let event_attrib name value = AStr (name, value)


(** Element *)

type ename = string
type econtent =
  | Empty
  | Comment of string
  | EncodedPCDATA of string
  | PCDATA of string
  | Entity of string
  | Leaf of ename * attrib list
  | Node of ename * attrib list * elt list
and elt = {
  elt : econtent ;
}

let content elt = elt.elt

let empty () = { elt = Empty }

let comment c = { elt = Comment c }

let pcdata d = { elt = PCDATA d }
let encodedpcdata d = { elt = EncodedPCDATA d }
let entity e = { elt = Entity e }

let cdata s = (* GK *)
  (* For security reasons, we do not allow "]]>" inside CDATA
     (as this string is to be considered as the end of the cdata)
  *)
  let s' = "\n<![CDATA[\n"^
    (Netstring_pcre.global_replace
       (Netstring_pcre.regexp_string "]]>") "" s)
    ^"\n]]>\n" in
  encodedpcdata s'

let cdata_script s = (* GK *)
  (* For security reasons, we do not allow "]]>" inside CDATA
     (as this string is to be considered as the end of the cdata)
  *)
  let s' = "\n//<![CDATA[\n"^
    (Netstring_pcre.global_replace
       (Netstring_pcre.regexp_string "]]>") "" s)
    ^"\n//]]>\n" in
  encodedpcdata s'

let cdata_style s = (* GK *)
  (* For security reasons, we do not allow "]]>" inside CDATA
     (as this string is to be considered as the end of the cdata)
  *)
  let s' = "\n/* <![CDATA[ */\n"^
    (Netstring_pcre.global_replace
       (Netstring_pcre.regexp_string "]]>") "" s)
    ^"\n/* ]]> */\n" in
  encodedpcdata s'

let leaf ?a name =
  { elt =
      (match a with
	 | Some a -> Leaf (name, a)
	 | None -> Leaf (name, [])) }

let node ?a name children =
  { elt =
      (match a with
	 | Some a -> Node (name, a, children)
	 | None -> Node (name, [], children)) }

