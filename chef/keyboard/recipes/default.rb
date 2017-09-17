ruby_block "set fast 'Key Repeat' preset" do
  not_if { ZZ::Exec.fast_key_repeat? }
  block { ZZ::Exec.set_fast_key_repeat }
end

ruby_block "set short 'Delay Until Repeat' preset" do
  not_if { ZZ::Exec.short_key_delay? }
  block { ZZ::Exec.set_short_key_delay }
end
