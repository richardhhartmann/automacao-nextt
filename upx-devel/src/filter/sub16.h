/* sub16.h -- simple delta filter

   This file is part of the UPX executable compressor.

   Copyright (C) 1996-2025 Markus Franz Xaver Johannes Oberhumer
   Copyright (C) 1996-2025 Laszlo Molnar
   All Rights Reserved.

   UPX and the UCL library are free software; you can redistribute them
   and/or modify them under the terms of the GNU General Public License as
   published by the Free Software Foundation; either version 2 of
   the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; see the file COPYING.
   If not, write to the Free Software Foundation, Inc.,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

   Markus F.X.J. Oberhumer              Laszlo Molnar
   <markus@oberhumer.com>               <ezerotven+github@gmail.com>
 */

/*************************************************************************
//
**************************************************************************/

#include "sub.hh"

#define SUB16(f, N)  SUB(f, N, unsigned short, get_le16, set_le16)
#define ADD16(f, N)  ADD(f, N, unsigned short, get_le16, set_le16)
#define SCAN16(f, N) SCAN(f, N, unsigned short, get_le16, set_le16)

/*************************************************************************
//
**************************************************************************/

// filter
static int f_sub16_1(Filter *f) { SUB16(f, 1) }

static int f_sub16_2(Filter *f) { SUB16(f, 2) }

static int f_sub16_3(Filter *f) { SUB16(f, 3) }

static int f_sub16_4(Filter *f) { SUB16(f, 4) }

// unfilter
static int u_sub16_1(Filter *f) { ADD16(f, 1) }

static int u_sub16_2(Filter *f) { ADD16(f, 2) }

static int u_sub16_3(Filter *f) { ADD16(f, 3) }

static int u_sub16_4(Filter *f) { ADD16(f, 4) }

// scan
static int s_sub16_1(Filter *f) { SCAN16(f, 1) }

static int s_sub16_2(Filter *f) { SCAN16(f, 2) }

static int s_sub16_3(Filter *f) { SCAN16(f, 3) }

static int s_sub16_4(Filter *f) { SCAN16(f, 4) }

#undef SUB
#undef ADD
#undef SCAN
#undef SUB16
#undef ADD16
#undef SCAN16

/* vim:set ts=4 sw=4 et: */
