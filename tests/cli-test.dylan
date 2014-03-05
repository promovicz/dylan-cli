module: cli-test
synopsis: Various tests for the CLI.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: see accompanying file LICENSE

define cli-root $simple-root;

define variable progress :: <symbol> = #"init";

define cli-command $simple-root (simple one)
  simple parameter alpha;
  implementation
    begin
      progress := #"one";
      check-equal("Value of alpha", "alpha-value", alpha);
    end;
end;

define cli-command $simple-root (simple two)
  named parameter alpha;
  named parameter beta;
  implementation
    begin
      progress := #"two";
      check-equal("Value of alpha", "alpha-value", alpha);
      check-equal("Value of beta",  "beta-value", beta);
    end;
end;

define cli-command $simple-root (simple three)
  simple parameter alpha;
  simple parameter beta;
  implementation
    begin
      progress := #"three";
      check-equal("Value of alpha", "alpha-value", alpha);
      check-equal("Value of beta",  "beta-value", beta);
    end;
end;

define test cli-integration-test()
  
end;


define test cli-tokenizer-test()
  local
    method make-source(string :: <string>)
      make(<cli-string-source>,
           string: string);
    end,
    method test-one(string :: <string>,
                    token-strings :: <list>,
                    token-types :: <list>,
                    token-starts :: <list>,
                    token-ends :: <list>)
      let source = make-source(string);
      let tokens = cli-tokenize(source);
      // check we got the right number of tokens
      check-equal(concatenate("token count in \"", string, "\""),
                  size(token-strings), size(tokens));
      // check against our fixtures
      check-equal(concatenate("token strings in \"", string, "\""),
                  token-strings, map(token-string, tokens));
      check-equal(concatenate("token types in \"", string, "\""),
                  token-types, map(token-type, tokens));
      check-equal(concatenate("token starts in \"", string, "\""),
                  token-starts, map(source-location-start-character,
                                    map(token-srcloc, tokens)));
      check-equal(concatenate("token ends in \"", string, "\""),
                  token-ends, map(source-location-end-character,
                                    map(token-srcloc, tokens)));
    end;

  test-one("a",
           #("a"),
           #(#"word"),
           #(0),
           #(0));
  test-one(" a ",
           #(" ", "a", " "),
           #(#"whitespace",#"word",#"whitespace"),
           #(0, 1, 2),
           #(0, 1, 2));
  test-one("a b c",
           #("a"," ","b"," ","c"),
           #(#"word",#"whitespace",#"word",#"whitespace",#"word"),
           #(0, 1, 2, 3, 4),
           #(0, 1, 2, 3, 4));
  test-one(" a b c ",
           #(" ","a"," ","b"," ","c"," "),
           #(#"whitespace",#"word",#"whitespace",#"word",#"whitespace",#"word",#"whitespace"),
           #(0, 1, 2, 3, 4, 5, 6),
           #(0, 1, 2, 3, 4, 5, 6));
  test-one("aa bb cc",
           #("aa"," ","bb"," ","cc"),
           #(#"word",#"whitespace",#"word",#"whitespace",#"word"),
           #(0, 2, 3, 5, 6),
           #(1, 2, 4, 5, 7));
  test-one(" aa bb cc ",
           #(" ","aa"," ","bb"," ","cc"," "),
           #(#"whitespace",#"word",#"whitespace",#"word",#"whitespace",#"word",#"whitespace"),
           #(0, 1, 3, 4, 6, 7, 9),
           #(0, 2, 3, 5, 6, 8, 9));
end;

define suite cli-test-suite()
  test cli-tokenizer-test;
end;

run-test-application(cli-test-suite);
