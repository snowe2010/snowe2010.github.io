;(function()
{
  // CommonJS
  SyntaxHighlighter = SyntaxHighlighter || (typeof require !== 'undefined'? require('shCore').SyntaxHighlighter : null);

  function Brush()
  {
    // Contributed by Erik Peterson.
  
    var keywords =  '__LINE__ __FILE__ __ENCODING__ __END__ alias and BEGIN begin break case class def define_method defined do each else elsif ' +
            'END end ensure false for if in include module new next nil not or raise redo rescue retry return ' +
            'self super then throw true undef unless until when while yield';

    var builtins =  'Array Bignum Binding Class Continuation Dir Exception FalseClass File::Stat File Fixnum Fload ' +
            'Hash Integer IO MatchData Method Module NilClass Numeric Object Proc Range Regexp String Struct::TMS Symbol ' +
            'ThreadGroup Thread Time TrueClass';

    var returnSecond = function addOne(match, regexInfo){ return match[1]; };

    this.regexList = [
      { regex: /#[^{].*[^}]/g,                                      css: 'comments',              nonest: true,   priority: 1                       },    // one line comments
      { regex: /".*?"/g,                                            css: 'string',                nonest: true,   priority: 2                       },    // double quoted strings
      { regex: SyntaxHighlighter.regexLib.singleQuotedString,       css: 'string',                nonest: false,  priority: 1                       },    // single quoted strings
      //{ regex: /#{.*}/g,                                          css: 'string_interpolation',  nonest: false,  priority: 3                       },    // string interpolation
      { regex: /\b[A-Z0-9_]+\b/g,                                  css: 'constants',             nonest: false,  priority: 3                       },    // constants
      { regex: /\B:[a-z][A-Za-z0-9_]*\b/g,                          css: 'color2',                nonest: false,  priority: 3                       },    // symbols
      { regex: /(?:def\s)(\w+\b)/g,                                 css: 'color3',                nonest: false,  priority: 3, func: returnSecond   },    // method name
      { regex: /\b(?:def\s\w.*?(\?|\b))(.*)/g,                      css: 'parameters',                nonest: false,  priority: 3, func: returnSecond   },
      { regex: /(\$|@@|@)\w+/g,                                     css: 'variable bold',         nonest: false,  priority: 3                       },    // $global, @instance, and @@class variables
      { regex: new RegExp(this.getKeywords(keywords), 'gm'),        css: 'keyword',               nonest: false,  priority: 3                       },    // keywords
      { regex: new RegExp(this.getKeywords(builtins), 'gm'),        css: 'color1',                nonest: false,  priority: 3                       }     // builtins
      ];

    this.forHtmlScript(SyntaxHighlighter.regexLib.aspScriptTags);
  };

  Brush.prototype = new SyntaxHighlighter.Highlighter();
  Brush.aliases = ['ruby', 'rails', 'ror', 'rb'];

  SyntaxHighlighter.brushes.Ruby = Brush;

  // CommonJS
  typeof(exports) != 'undefined' ? exports.Brush = Brush : null;
})();
