/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseTags.h                                           *
 *                                                        *
 * hprose tags header for Objective-C.                    *
 *                                                        *
 * LastModified: Apr 10, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

enum {
    /* Serialize Tags */
    HproseTagInteger = 'i',
    HproseTagLong = 'l',
    HproseTagDouble = 'd',
    HproseTagNull = 'n',
    HproseTagEmpty = 'e',
    HproseTagTrue = 't',
    HproseTagFalse = 'f',
    HproseTagNaN = 'N',
    HproseTagInfinity = 'I',
    HproseTagDate = 'D',
    HproseTagTime = 'T',
    HproseTagUTC = 'Z',
    HproseTagBytes = 'b',
    HproseTagUTF8Char = 'u',
    HproseTagString = 's',
    HproseTagGuid = 'g',
    HproseTagList = 'a',
    HproseTagMap = 'm',
    HproseTagClass = 'c',
    HproseTagObject = 'o',
    HproseTagRef = 'r',
    /* Serialize Marks */
    HproseTagPos = '+',
    HproseTagNeg = '-',
    HproseTagSemicolon = ';',
    HproseTagOpenbrace = '{',
    HproseTagClosebrace = '}',
    HproseTagQuote = '"',
    HproseTagPoint = '.',
    /* Protocol Tags */
    HproseTagFunctions = 'F',
    HproseTagCall = 'C',
    HproseTagResult = 'R',
    HproseTagArgument = 'A',
    HproseTagError = 'E',
    HproseTagEnd = 'z',
};