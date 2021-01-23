class Object
  def open_tk_console(b = binding, modal = true)
    @@main_console ||= TkInspect::Console::Base.new(modal: modal)
    @@main_console.eval_binding = b
    @@main_console.focus
    modal ? @@main_console.modal_loop : Tk.mainloop
  end
  alias otkc open_tk_console
end
