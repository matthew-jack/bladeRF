-- Copyright (c) 2018 Nuand LLC
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

library nuand;
    use nuand.util.all;

library std;
    use std.env.all;
    use std.textio.all;

library work;
    use work.tone_generator_p.all;

entity tone_generator_tb is
    generic (
        CLOCK_FREQUENCY             : natural   := 1_920_000;
        OFFSET_FREQUENCY            : natural   := 10_000;
        TONE_FREQUENCY              : natural   := 1_000;
        TONE_DURATION               : time      := 300 us
    );
end entity;

architecture arch of tone_generator_tb is
    signal clock    : std_logic     := '1';
    signal reset    : std_logic     := '1';

    signal inputs   : tone_generator_input_t    := (period      => 0,
                                                    duration    => 0,
                                                    valid       => '0');
    signal outputs  : tone_generator_output_t;

    constant CLOCK_PERIOD : time := 1 sec / CLOCK_FREQUENCY;
begin

    clock <= not clock after CLOCK_PERIOD/2;

    U_tone_generator : entity work.tone_generator
      port map (
        clock   => clock,
        reset   => reset,
        inputs  => inputs,
        outputs => outputs
      );

    tb : process
    begin
        -- reset
        reset <= '1';
        nop(clock, 10);

        reset <= '0';
        nop(clock, 10);

        -- start tone
        inputs.period   <= 1 sec / (TONE_FREQUENCY + OFFSET_FREQUENCY) / CLOCK_PERIOD;
        inputs.duration <= TONE_DURATION / CLOCK_PERIOD;
        inputs.valid <= '1';
        wait until rising_edge(clock);
        inputs.valid <= '0';
        wait until rising_edge(clock);

        -- wait a bit
        for i in 0 to (1.1 * TONE_DURATION) / CLOCK_PERIOD loop
            wait until rising_edge(clock);
        end loop;

        -- send new tone, at twice the frequency
        inputs.period   <= 1 sec / (TONE_FREQUENCY*2 + OFFSET_FREQUENCY) / CLOCK_PERIOD;
        inputs.duration <= TONE_DURATION / CLOCK_PERIOD;
        inputs.valid <= '1';
        wait until rising_edge(clock);
        inputs.valid <= '0';
        wait until rising_edge(clock);

        wait;
    end process ;

end architecture;
