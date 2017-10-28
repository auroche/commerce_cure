defmodule Pukey.DecoderTest do
  use ExUnit.Case
  import Pukey.Decoder

  @xml """
  <result>
    <event>
      <title>My event</title>
      <artist>
        <name>Michael Jackson</name>
      </artist>
    </event>
    <event>
      <title>My event 2</title>
      <artist>
        <name>Rolling Stones</name>
      </artist>
    </event>
  </result>
  """

  test "decode xml" do
    assert [result: [
      event: [title: "My event", artist: [name: "Michael Jackson"]],
      event: [title: "My event 2", artist: [name: "Rolling Stones"]]]
    ]
    = decode(@xml)
  end
end
