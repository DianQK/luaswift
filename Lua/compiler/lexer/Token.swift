//
//  Token.swift
//  Lua
//
//  Created by dianqk on 2020/9/28.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

// token kind
enum RawTokenKind {
    case eof           // end-of-file
    case vararg                        // ...
    case semicolon                       // ;
    case comma                      // ,
    case dot                        // .
    case colon                     // :
    case label                     // ::
    case leftParen                    // (
    case rightParen                    // )
    case leftSquareBracket                    // [
    case rightSquareBracket                    // ]
    case leftBrace                   // { leftCurly
    case rightBrace                   // } rightCurly
    case equal                    // =
    case minusOperator                     // - (sub or unm)
    case unaryMinusOperator                    // unary minus
    case subOperator                   // minus
    case waveOperator                      // ~ (bnot or bxor)
    case bnotOperator                    // wave
    case bxorOperator                    // wave
    case addOperator                        // +
    case mulOperator                        // *
    case divOperator                       // /
    case idivOperator                       // //
    case powOperator                        // ^
    case modOperator                        // %
    case bandOperator                       // &
    case borOperator                        // |
    case shrOperator                        // >>
    case shlOperator                       // <<
    case concatOperator                     // ..
    case ltOperator                         // <
    case leOperator                         // <=
    case gtOperator                        // >
    case geOperator                        // >=
    case eqOperator                        // ==
    case neOperator                        // ~=
    case lenOperator                       // #
    case andOperator                        // and
    case orOperator                         // or
    case notOperator                        // not
    case breakKeyword                     // break
    case doKeyword                         // do
    case elseKeyword                       // else
    case elseifKeyword                     // elseif
    case endKeyword                        // end
    case falseKeyword                      // false
    case forKeyword                        // for
    case functionKeyword                   // function
    case gotoKeyword                       // goto
    case ifKeyword                         // if
    case inKeyword                         // in
    case localKeyword                      // local
    case nilKeyword                        // nil
    case repeatKeyword                     // repeat
    case returnKeyword                     // return
    case thenKeyword                       // then
    case trueKeyword                       // true
    case untilKeyword                      // until
    case whileKeyword                      // while
    case identifier                    // identifier
    case number                        // number literal
    case string                       // string literal

    var category: TokenCategory {
        switch self {
        case .eof, .vararg, .semicolon:
            return .other
        case .comma, .dot, .colon, .label, .leftParen, .rightParen, .leftBrace, .rightBrace, .leftSquareBracket, .rightSquareBracket:
            return .separator
        case .equal, .minusOperator, .unaryMinusOperator, .subOperator, .waveOperator, .bnotOperator, .bxorOperator, .addOperator, .mulOperator, .divOperator, .idivOperator, .powOperator, .modOperator, .bandOperator, .borOperator, .shrOperator, .shlOperator, .concatOperator, .ltOperator, .leOperator, .gtOperator, .geOperator, .eqOperator, .neOperator, .lenOperator, .andOperator, .orOperator, .notOperator:
            return .operator
        case .breakKeyword, .doKeyword, .elseKeyword, .elseifKeyword, .endKeyword, .falseKeyword, .forKeyword, .functionKeyword, .gotoKeyword, .ifKeyword, .inKeyword, .localKeyword, .nilKeyword, .repeatKeyword, .returnKeyword, .thenKeyword, .trueKeyword, .untilKeyword, .whileKeyword:
            return .keyword
        case .identifier:
            return .identifier
        case .number:
            return .number
        case .string:
            return .string
        }
    }
}

enum TokenCategory: String {

    case other
    case separator
    case `operator`
    case keyword
    case identifier
    case number
    case string

}
