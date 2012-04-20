package ru.org.linux.util.formatter;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class ToLorCodeFormatterTest {
  private static final String QUOTING1 = "> 1";
  private static final String RESULT_QUOTING1 = "[quote] 1[/quote]";

  private static final String QUOTING2 = "> 1\n2";
  private static final String RESULT_QUOTING2 = "[quote] 1[br][/quote]2";

  private static final String QUOTING3 = "> 1\n2\n\n3";
  private static final String RESULT_QUOTING3 = "[quote] 1[br][/quote]2\n\n3";

  private ToLorCodeTexFormatter toLorCodeTexFormatter = new ToLorCodeTexFormatter();
  private ToLorCodeFormatter toLorCodeFormatter = new ToLorCodeFormatter();

  @Test
  public void testToLorCodeTexFormatter() {
    assertEquals(RESULT_QUOTING1, toLorCodeTexFormatter.format(QUOTING1));
    assertEquals(RESULT_QUOTING2, toLorCodeTexFormatter.format(QUOTING2));
    assertEquals(RESULT_QUOTING3, toLorCodeTexFormatter.format(QUOTING3));

    assertEquals("[quote]test[br][/quote]test", toLorCodeTexFormatter.format(">test\n\ntest")); // 4
    assertEquals("test\n\ntest\ntest", toLorCodeTexFormatter.format("test\n\ntest\ntest")); // 1
    assertEquals("test\n\n[quote]test[/quote]", toLorCodeTexFormatter.format("test\n\n>test")); // 7
    assertEquals("test &", toLorCodeTexFormatter.format("test &")); // 8
    assertEquals("test[br]test", toLorCodeFormatter.format("test\r\ntest", true)); // 9
    assertEquals("test[br]test", toLorCodeFormatter.format("test\ntest", true)); // 10
    assertEquals("[quote]test[br][/quote]test", toLorCodeFormatter.format(">test\ntest", true)); // 11
    assertEquals("[quote]test[br]test[/quote]", toLorCodeFormatter.format(">test\n>test", true)); // 12
  }

  @Test
  public void codeEscapeBasic() {
    assertEquals("[[code]]", ToLorCodeTexFormatter.escapeCode("[code]"));
    assertEquals(" [[code]]", ToLorCodeTexFormatter.escapeCode(" [code]"));
    assertEquals("[[/code]]", ToLorCodeTexFormatter.escapeCode("[/code]"));
    assertEquals(" [[/code]]", ToLorCodeTexFormatter.escapeCode(" [/code]"));
    assertEquals("[[code]]", ToLorCodeTexFormatter.escapeCode("[[code]]"));
    assertEquals(" [[code]]", ToLorCodeTexFormatter.escapeCode(" [[code]]"));
    assertEquals(" [[/code]]", ToLorCodeTexFormatter.escapeCode(" [[/code]]"));

    assertEquals("][[code]]", ToLorCodeTexFormatter.escapeCode("][code]"));
    assertEquals("[[code]] [[code]]", ToLorCodeTexFormatter.escapeCode("[code] [code]"));
    assertEquals("[[code]] [[/code]]", ToLorCodeTexFormatter.escapeCode("[code] [/code]"));

    // TODO
    //     assertEquals("[[code]][[code]]", ToLorCodeTexFormatter.escapeCode("[code][code]"));
  }

  @Test
  public void codeEscape() {
    assertEquals("[code][/code]",
        toLorCodeTexFormatter.format("[code][/code]"));
    assertEquals("[code=perl][/code]",
        toLorCodeTexFormatter.format("[code=perl][/code]"));
    assertEquals("[[code]] [[/code]]",
        toLorCodeFormatter.format("[code] [/code]", true));
    assertEquals("[[code=perl]] [[/code]]",
        toLorCodeFormatter.format("[code=perl] [/code]", true));
  }

  @Test
  public void codeAndQuoteTest() {
    assertEquals(
            "[quote] test [br][/quote][code]\n" +
            "> test\n" +
            "[/code]",
            toLorCodeTexFormatter.format(
                    "> test \n\n"+
                    "[code]\n"+
                    "> test\n"+
                    "[/code]")
    );

    assertEquals(
            "[quote] test [br][/quote][code]\n" +
            "> test\n" +
            "[/code]",
            toLorCodeTexFormatter.format(
                    "> test \n"+
                    "[code]\n"+
                    "> test\n"+
                    "[/code]")
    );

    assertEquals(
            "[quote] test [br] [[code]] [br] test [/quote]",
            toLorCodeTexFormatter.format(
                    "> test \n"+
                    "> [code] \n"+
                    "> test \n")
    );

    assertEquals(
            "[quote] test [[code]] [br] test[br] test [[/code]][/quote]",
            toLorCodeTexFormatter.format(
                    "> test [code] \n"+
                    "> test\n"+
                    "> test [/code]\n")
    );

    assertEquals(
            "[code]test[/code]\n" +
            "[quote] test[/quote]",
            toLorCodeTexFormatter.format(
                    "[code]test[/code]\n"+
                    "> test\n")
    );

    assertEquals(
            "[[code]] test",
            toLorCodeTexFormatter.format(
              "[[code]] test"
            )
    );

    assertEquals(
            "[quote] [[code]] test[/quote]",
            toLorCodeTexFormatter.format(
              "> [[code]] test"
            )
    );
  }

  @Test
  public void againQuoteFormatter() {
    assertEquals("[quote]one[br][quote]two[br][/quote]one[br][quote][quote]three[/quote][/quote][/quote]",
        toLorCodeFormatter.format(">one\n>>two\n>one\n>>>three", true));
    assertEquals("[quote]one[br][quote]two[br][/quote]one[br][quote][quote]three[/quote][/quote][/quote]",
        toLorCodeTexFormatter.format(">one\n>>two\n>one\n>>>three"));
  }
}
