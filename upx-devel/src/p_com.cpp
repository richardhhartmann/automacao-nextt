/* p_com.cpp -- dos/com executable format

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

#include "conf.h"
#include "file.h"
#include "filter.h"
#include "packer.h"
#include "p_com.h"
#include "linker.h"

static const CLANG_FORMAT_DUMMY_STATEMENT
#include "stub/i086-dos16.com.h"

/*************************************************************************
//
**************************************************************************/

Linker *PackCom::newLinker() const { return new ElfLinkerX86(); }

const int *PackCom::getCompressionMethods(int method, int level) const {
    static const int m_nrv2b[] = {M_NRV2B_LE16, M_END};
    UNUSED(method);
    UNUSED(level);
    return m_nrv2b;
}

const int *PackCom::getFilters() const {
    // see class FilterImpl
    static const int filters[] = {0x06, 0x03, 0x04, 0x01, 0x05, 0x02, FT_END};
    return filters;
}

/*************************************************************************
//
**************************************************************************/

tribool PackCom::canPack() {
    byte buf[128];

    fi->readx(buf, sizeof(buf));
    if (memcmp(buf, "MZ", 2) == 0 || memcmp(buf, "ZM", 2) == 0) // .exe
        return false;
    if (memcmp(buf, "\xff\xff\xff\xff", 4) == 0) // .sys
        return false;
    if (!fn_has_ext(fi->getName(), "com")) // query file name
        return false;
    checkAlreadyPacked(buf, sizeof(buf));
    if (file_size < 1024)
        throwCantPack("file is too small for dos/com");
    if (file_size > 0xFF00)
        throwCantPack("file is too large for dos/com");
    return true;
}

/*************************************************************************
//
**************************************************************************/

void PackCom::addFilter16(int filter_id) {
    assert(filter_id > 0);
    assert(isValidFilter(filter_id));

    if (filter_id % 3 == 0) {
        // clang-format off
        addLoader("CALLTR16",
                  filter_id < 4 ? "CT16SUB0" : "",
                  filter_id < 4 ? "" : (opt->cpu_x86 == opt->CPU_8086 ? "CT16I086" : "CT16I286,CT16SUB0"),
                  "CALLTRI2",
                  getFormat() == UPX_F_DOS_COM ? "CORETURN" : "");
        // clang-format on
    } else {
        // clang-format off
        addLoader(filter_id % 3 == 1 ? "CT16E800" : "CT16E900",
                 "CALLTRI5",
                 getFormat() == UPX_F_DOS_COM ? "CT16JEND" : "CT16JUL2",
                 filter_id < 4 ? "CT16SUB1" : "",
                 filter_id < 4 ? "" : (opt->cpu_x86 == opt->CPU_8086 ? "CT16I087" : "CT16I287,CT16SUB1"),
                 "CALLTRI6");
        // clang-format on
    }
}

void PackCom::buildLoader(const Filter *ft) {
    initLoader(stub_i086_dos16_com, sizeof(stub_i086_dos16_com));
    // clang-format off
    addLoader("COMMAIN1",
              ph.first_offset_found == 1 ? "COMSBBBP" : "",
              "COMPSHDI",
              ft->id ? "COMCALLT" : "",
              "COMMAIN2,UPX1HEAD,COMCUTPO,NRV2B160",
              ft->id ? "NRVDDONE" : "NRVDRETU",
              "NRVDECO1",
              ph.max_offset_found <= 0xd00 ? "NRVLED00" : "NRVGTD00",
              "NRVDECO2");
    // clang-format on
    if (ft->id) {
        assert(ft->calls > 0);
        addFilter16(ft->id);
    }
}

void PackCom::patchLoader(OutputFile *fo, byte *loader, int lsize, unsigned calls) {
    const int e_len = getLoaderSectionStart("COMCUTPO");
    const int d_len = lsize - e_len;
    assert(e_len > 0 && e_len < 128);
    assert(d_len > 0 && d_len < 256);

    const unsigned upper_end = ph.u_len + ph.overlap_overhead + d_len + 0x100;
    unsigned stacksize = 0x60;
    if (upper_end + stacksize > 0xfffe)
        stacksize = 0x56;
    if (upper_end + stacksize > 0xfffe)
        throwCantPack("file is too large for dos/com");

    linker->defineSymbol("calltrick_calls", calls);
    linker->defineSymbol("sp_limit", upper_end + stacksize);
    linker->defineSymbol("bytes_to_copy", ph.c_len + lsize);
    linker->defineSymbol("copy_source", ph.c_len + lsize + 0x100);
    linker->defineSymbol("copy_destination", upper_end);
    linker->defineSymbol("neg_e_len", 0 - e_len);
    linker->defineSymbol("NRV2B160", ph.u_len + ph.overlap_overhead);

    relocateLoader();
    loader = getLoader();

    // some day we could use the relocation stuff for patchPackHeader too..
    patchPackHeader(loader, e_len);
    // write loader + compressed file
    fo->write(loader, e_len);         // entry
    fo->write(obuf, ph.c_len);        // compressed
    fo->write(loader + e_len, d_len); // decompressor
    NO_printf("%-13s: entry        : %8u bytes\n", getName(), e_len);
    NO_printf("%-13s: compressed   : %8u bytes\n", getName(), ph.c_len);
    NO_printf("%-13s: decompressor : %8u bytes\n", getName(), d_len);
}

/*************************************************************************
//
**************************************************************************/

void PackCom::pack(OutputFile *fo) {
    // read file
    ibuf.alloc(file_size);
    obuf.allocForCompression(file_size);
    fi->seek(0, SEEK_SET);
    fi->readx(ibuf, file_size);

    // prepare packheader
    ph.u_len = file_size;
    // prepare filter
    Filter ft(ph.level);
    ft.addvalue = getCallTrickOffset();
    // compress
    const unsigned overlap_range = ph.u_len < 0xFE00 - ft.addvalue ? 32 : 0;
    compressWithFilters(&ft, overlap_range, NULL_cconf);

    const int lsize = getLoaderSize();
    MemBuffer loader(lsize);
    memcpy(loader, getLoader(), lsize);

    const unsigned calls = ft.id % 3 ? ft.lastcall - 2 * ft.calls : ft.calls;
    patchLoader(fo, loader, lsize, calls);

    // verify
    verifyOverlappingDecompression();

    // finally check the compression ratio
    if (!checkFinalCompressionRatio(fo))
        throwNotCompressible();
}

/*************************************************************************
//
**************************************************************************/

tribool PackCom::canUnpack() {
    if (!readPackHeader(128)) // read "ph"
        return false;
    if (file_size_u <= ph.c_len)
        return false;
    return true;
}

/*************************************************************************
//
**************************************************************************/

void PackCom::unpack(OutputFile *fo) {
    ibuf.alloc(file_size);
    obuf.allocForDecompression(ph.u_len);

    // read whole file
    fi->seek(0, SEEK_SET);
    fi->readx(ibuf, file_size);

    // get compressed data offset
    unsigned e_len = ph.buf_offset + ph.getPackHeaderSize();
    if (file_size_u <= e_len + ph.c_len)
        throwCantUnpack("file damaged");

    // decompress
    decompress(ibuf + e_len, obuf);

    // unfilter
    Filter ft(ph.level);
    ft.init(ph.filter, getCallTrickOffset());
    ft.unfilter(obuf, ph.u_len);

    // write decompressed file
    if (fo)
        fo->write(obuf, ph.u_len);
}

/* vim:set ts=4 sw=4 et: */
