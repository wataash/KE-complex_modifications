#!/usr/bin/env ruby

require 'json'
require_relative '../lib/karabiner.rb'
require_relative 'emacs_key_bindings.json'

$m_emacs = [
  *control_keys(
    :type => :generic,
    :description => 'wataash2: Emacs key bindings [left_control+keys]',
    :frontmost_application_unless => [Karabiner.frontmost_application_unless(['emacs', 'terminal', 'vi'])],
    :frontmost_application_if => []
  )['manipulators'],
  *option_keys(
    :type => :generic,
    :description => 'wataash2: Emacs key bindings [left_option+keys]',
    :frontmost_application_unless => [Karabiner.frontmost_application_unless(['emacs', 'terminal', 'vi'])],
    :frontmost_application_if => []
  )['manipulators'],
  *bash_style(
    :type => :generic,
    :description => 'wataash2: Bash style Emacs key bindings',
    :frontmost_application_unless => [Karabiner.frontmost_application_unless(['emacs', 'terminal', 'vi'])],
    :frontmost_application_if => []
  )['manipulators'],
]

$m_emacs = $m_emacs.map do |m|
  if m['from']['modifiers']['mandatory'] == ['control']
    m['from']['modifiers']['mandatory'] = ['left_control']
    # allow any optional modifiers
    # https://pqrs.org/osx/karabiner/json.html#from-event-definition-modifiers
    # > Events are also manipulated even if optional modifiers are pressed.
    # > Optional modifiers are kept in to events.
    # example: enable ctrl+cmd+option+shift+A -> cmd+option+shift+Home
    m['from']['modifiers']['optional'] = ['any']
  elsif m['from']['modifiers']['mandatory'] == ['option']
    m['from']['modifiers']['mandatory'] = ['left_option']
  else
    raise 'unexpected mandatory-modifiers'
  end

  m
end

$m_emacs.append(
  type: 'basic',
  from: {
    key_code: 'g',
    modifiers: Karabiner.from_modifiers(['left_control'], ['any']),
  },
  to: [{ key_code: 'escape' }],
  conditions: [Karabiner.frontmost_application_unless(['emacs', 'terminal', 'vi'])],
)

$m_emacs.append(
  type: 'basic',
  from: {
    key_code: 'j',
    modifiers: Karabiner.from_modifiers(['left_control'], ['any']),
  },
  to: [{ key_code: 'return_or_enter' }],
  conditions: [Karabiner.frontmost_application_unless(['emacs', 'terminal', 'vi'])],
)

# puts JSON.pretty_generate($m_emacs)

def kfm *arg
  Karabiner.from_modifiers *arg
end

$m = [
=begin
  # ---------------------------------------------------------------------------
  # terminal: left_control<->right_control left_option<->right_option
  # to avoid emacs_key_bindings.json
  # c.f. remote-desktop.json, ag iterm
  { type: 'basic', from: { key_code: 'left_control',           modifiers: { optional: ['any'] } },                                to: [{ key_code: 'right_control' }],  conditions: [{ "type": "frontmost_application_if", "bundle_identifiers": ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"] }] },
  { type: 'basic', from: { key_code: 'right_control',          modifiers: { optional: ['any'] } },                                to: [{ key_code: 'left_control' }],   conditions: [{ "type": "frontmost_application_if", "bundle_identifiers": ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"] }] },
  { type: 'basic', from: { key_code: 'left_option',            modifiers: { optional: ['any'] } },                                to: [{ key_code: 'right_option' }],   conditions: [{ "type": "frontmost_application_if", "bundle_identifiers": ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"] }] },
  { type: 'basic', from: { key_code: 'right_option',           modifiers: { optional: ['any'] } },                                to: [{ key_code: 'left_option' }],    conditions: [{ "type": "frontmost_application_if", "bundle_identifiers": ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"] }] },
=end
  # ---------------------------------------------------------------------------
  # JerBrains: ctrl+shift+[ae] → shift+{home,end}
  # Java GUIなのでmacOSのemacsキーバインドは独自解釈するっぽい
  #                                                            modifiers: { mandatory: ['left_control', 'shift'], optional: ['any'] },
  { type: 'basic', from: { key_code: 'e',                      modifiers: kfm(['left_control', 'shift'], ['any']) },              to: [{ key_code: 'end', modifiers: ['left_shift'] }],       conditions: [Karabiner.frontmost_application_if(['jetbrains_ide'])]  },
  { type: 'basic', from: { key_code: 'a',                      modifiers: kfm(['left_control', 'shift'], ['any']) },              to: [{ key_code: 'home', modifiers: ['left_shift'] }],      conditions: [Karabiner.frontmost_application_if(['jetbrains_ide'])]  },
  # ---------------------------------------------------------------------------
  # ---------- ^^^^^^^^^^ based on @tekezo
  { type: 'basic', from: { key_code: 'hyphen',                 modifiers: kfm(['left_control'], ['caps_lock']), },                to: 9.times.map { { key_code: 'hyphen' } }.append({ key_code: 'hyphen', repeat: false })          },
  { type: 'basic', from: { key_code: 'equal_sign',             modifiers: kfm(['left_control'], ['caps_lock']), },                to: 9.times.map { { key_code: 'equal_sign' } }.append({ key_code: 'equal_sign', repeat: false })  },
  # with shift: 70 chars
  { type: 'basic', from: { key_code: 'hyphen',                 modifiers: kfm(['left_control', 'shift'], ['caps_lock']), },       to: 69.times.map { { key_code: 'hyphen' } }.append({ key_code: 'hyphen', repeat: false })         },
  { type: 'basic', from: { key_code: 'equal_sign',             modifiers: kfm(['left_control', 'shift'], ['caps_lock']), },       to: 69.times.map { { key_code: 'equal_sign' } }.append({ key_code: 'equal_sign', repeat: false }) },

  # https://github.com/tekezo/Karabiner-Elements/issues/925

  # Controls and symbols
  { type: 'basic', from: { key_code: 'return_or_enter',        modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh return_or_enter"                        }] },
  { type: 'basic', from: { key_code: 'escape',                 modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh escape"                                 }] },
  { type: 'basic', from: { key_code: 'delete_or_backspace',    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh delete_or_backspace"                    }] },
  { type: 'basic', from: { key_code: 'delete_forward',         modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh delete_forward"                         }] },
  { type: 'basic', from: { key_code: 'tab',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh tab"                                    }] },
  { type: 'basic', from: { key_code: 'spacebar',               modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh spacebar"                               }] },
  { type: 'basic', from: { key_code: 'hyphen',                 modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh hyphen"                                 }] },
  { type: 'basic', from: { key_code: 'equal_sign',             modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh equal_sign"                             }] },
  { type: 'basic', from: { key_code: 'open_bracket',           modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh open_bracket"                           }] },
  { type: 'basic', from: { key_code: 'close_bracket',          modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh close_bracket"                          }] },
  { type: 'basic', from: { key_code: 'backslash',              modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh backslash"                              }] },
  { type: 'basic', from: { key_code: 'non_us_pound',           modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh non_us_pound"                           }] },
  { type: 'basic', from: { key_code: 'semicolon',              modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh semicolon"                              }] },
  { type: 'basic', from: { key_code: 'quote',                  modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh quote"                                  }] },
  { type: 'basic', from: { key_code: 'grave_accent_and_tilde', modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh grave_accent_and_tilde"                 }] },
  { type: 'basic', from: { key_code: 'comma',                  modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh comma"                                  }] },
  { type: 'basic', from: { key_code: 'period',                 modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh period"                                 }] },
  { type: 'basic', from: { key_code: 'slash',                  modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh slash"                                  }] },
  { type: 'basic', from: { key_code: 'non_us_backslash',       modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh non_us_backslash"                       }] },
  # Arrow keys
  { type: 'basic', from: { key_code: 'up_arrow',               modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh up_arrow"                               }] },
  { type: 'basic', from: { key_code: 'down_arrow',             modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh down_arrow"                             }] },
  { type: 'basic', from: { key_code: 'left_arrow',             modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh left_arrow"                             }] },
  { type: 'basic', from: { key_code: 'right_arrow',            modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh right_arrow"                            }] },
  { type: 'basic', from: { key_code: 'page_up',                modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh page_up"                                }] },
  { type: 'basic', from: { key_code: 'page_down',              modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh page_down"                              }] },
  { type: 'basic', from: { key_code: 'home',                   modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh home"                                   }] },
  { type: 'basic', from: { key_code: 'end',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh end"                                    }] },
  # Letter keys
  { type: 'basic', from: { key_code: 'a',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh a"                                      }] },
  { type: 'basic', from: { key_code: 'b',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh b"                                      }] },
  { type: 'basic', from: { key_code: 'c',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh c"                                      }] },
  { type: 'basic', from: { key_code: 'd',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh d"                                      }] },
  { type: 'basic', from: { key_code: 'e',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh e"                                      }] },
  { type: 'basic', from: { key_code: 'f',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f"                                      }] },
  { type: 'basic', from: { key_code: 'g',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh g"                                      }] },
  { type: 'basic', from: { key_code: 'h',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh h"                                      }] },
  { type: 'basic', from: { key_code: 'i',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh i"                                      }] },
  { type: 'basic', from: { key_code: 'j',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh j"                                      }] },
  { type: 'basic', from: { key_code: 'k',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh k"                                      }] },
  { type: 'basic', from: { key_code: 'l',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh l"                                      }] },
  { type: 'basic', from: { key_code: 'm',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh m"                                      }] },
  { type: 'basic', from: { key_code: 'n',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh n"                                      }] },
  { type: 'basic', from: { key_code: 'o',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh o"                                      }] },
  { type: 'basic', from: { key_code: 'p',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh p"                                      }] },
  { type: 'basic', from: { key_code: 'q',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh q"                                      }] },
  { type: 'basic', from: { key_code: 'r',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh r"                                      }] },
  { type: 'basic', from: { key_code: 's',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh s"                                      }] },
  { type: 'basic', from: { key_code: 't',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh t"                                      }] },
  { type: 'basic', from: { key_code: 'u',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh u"                                      }] },
  { type: 'basic', from: { key_code: 'v',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh v"                                      }] },
  { type: 'basic', from: { key_code: 'w',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh w"                                      }] },
  { type: 'basic', from: { key_code: 'x',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh x"                                      }] },
  { type: 'basic', from: { key_code: 'y',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh y"                                      }] },
  { type: 'basic', from: { key_code: 'z',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh z"                                      }] },
  # Number keys
  { type: 'basic', from: { key_code: '0',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh 0"                                      }] },
  { type: 'basic', from: { key_code: '1',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh 1"                                      }] },
  { type: 'basic', from: { key_code: '2',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh 2"                                      }] },
  { type: 'basic', from: { key_code: '3',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh 3"                                      }] },
  { type: 'basic', from: { key_code: '4',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh 4"                                      }] },
  { type: 'basic', from: { key_code: '5',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh 5"                                      }] },
  { type: 'basic', from: { key_code: '6',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh 6"                                      }] },
  { type: 'basic', from: { key_code: '7',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh 7"                                      }] },
  { type: 'basic', from: { key_code: '8',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh 8"                                      }] },
  { type: 'basic', from: { key_code: '9',                      modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh 9"                                      }] },
  # Function keys
  { type: 'basic', from: { key_code: 'f1',                     modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f1"                                     }] },
  { type: 'basic', from: { key_code: 'f2',                     modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f2"                                     }] },
  { type: 'basic', from: { key_code: 'f3',                     modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f3"                                     }] },
  { type: 'basic', from: { key_code: 'f4',                     modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f4"                                     }] },
  { type: 'basic', from: { key_code: 'f5',                     modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f5"                                     }] },
  { type: 'basic', from: { key_code: 'f6',                     modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f6"                                     }] },
  { type: 'basic', from: { key_code: 'f7',                     modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f7"                                     }] },
  { type: 'basic', from: { key_code: 'f8',                     modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f8"                                     }] },
  { type: 'basic', from: { key_code: 'f9',                     modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f9"                                     }] },
  { type: 'basic', from: { key_code: 'f10',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f10"                                    }] },
  { type: 'basic', from: { key_code: 'f11',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f11"                                    }] },
  { type: 'basic', from: { key_code: 'f12',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f12"                                    }] },
  { type: 'basic', from: { key_code: 'f13',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f13"                                    }] },
  { type: 'basic', from: { key_code: 'f14',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f14"                                    }] },
  { type: 'basic', from: { key_code: 'f15',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f15"                                    }] },
  { type: 'basic', from: { key_code: 'f16',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f16"                                    }] },
  { type: 'basic', from: { key_code: 'f17',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f17"                                    }] },
  { type: 'basic', from: { key_code: 'f18',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f18"                                    }] },
  { type: 'basic', from: { key_code: 'f19',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f19"                                    }] },
  { type: 'basic', from: { key_code: 'f20',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f20"                                    }] },
  { type: 'basic', from: { key_code: 'f21',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f21"                                    }] },
  { type: 'basic', from: { key_code: 'f22',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f22"                                    }] },
  { type: 'basic', from: { key_code: 'f23',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f23"                                    }] },
  { type: 'basic', from: { key_code: 'f24',                    modifiers: kfm(['right_option'         ], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh f24"                                    }] },

  # Controls and symbols
  { type: 'basic', from: { key_code: 'return_or_enter',        modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+return_or_enter"                  }] },
  { type: 'basic', from: { key_code: 'escape',                 modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+escape"                           }] },
  { type: 'basic', from: { key_code: 'delete_or_backspace',    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+delete_or_backspace"              }] },
  { type: 'basic', from: { key_code: 'delete_forward',         modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+delete_forward"                   }] },
  { type: 'basic', from: { key_code: 'tab',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+tab"                              }] },
  { type: 'basic', from: { key_code: 'spacebar',               modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+spacebar"                         }] },
  { type: 'basic', from: { key_code: 'hyphen',                 modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+hyphen"                           }] },
  { type: 'basic', from: { key_code: 'equal_sign',             modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+equal_sign"                       }] },
  { type: 'basic', from: { key_code: 'open_bracket',           modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+open_bracket"                     }] },
  { type: 'basic', from: { key_code: 'close_bracket',          modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+close_bracket"                    }] },
  { type: 'basic', from: { key_code: 'backslash',              modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+backslash"                        }] },
  { type: 'basic', from: { key_code: 'non_us_pound',           modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+non_us_pound"                     }] },
  { type: 'basic', from: { key_code: 'semicolon',              modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+semicolon"                        }] },
  { type: 'basic', from: { key_code: 'quote',                  modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+quote"                            }] },
  { type: 'basic', from: { key_code: 'grave_accent_and_tilde', modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+grave_accent_and_tile"            }] },
  { type: 'basic', from: { key_code: 'comma',                  modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+comma"                            }] },
  { type: 'basic', from: { key_code: 'period',                 modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+period"                           }] },
  { type: 'basic', from: { key_code: 'slash',                  modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+slash"                            }] },
  { type: 'basic', from: { key_code: 'non_us_backslash',       modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+non_us_backslash"                 }] },
  # Arrow keys
  { type: 'basic', from: { key_code: 'up_arrow',               modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+up_arrow"                         }] },
  { type: 'basic', from: { key_code: 'down_arrow',             modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+down_arrow"                       }] },
  { type: 'basic', from: { key_code: 'left_arrow',             modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+left_arrow"                       }] },
  { type: 'basic', from: { key_code: 'right_arrow',            modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+right_arrow"                      }] },
  { type: 'basic', from: { key_code: 'page_up',                modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+page_up"                          }] },
  { type: 'basic', from: { key_code: 'page_down',              modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+page_down"                        }] },
  { type: 'basic', from: { key_code: 'home',                   modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+home"                             }] },
  { type: 'basic', from: { key_code: 'end',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+end"                              }] },
  # Letter keys
  { type: 'basic', from: { key_code: 'a',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+a"                                }] },
  { type: 'basic', from: { key_code: 'b',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+b"                                }] },
  { type: 'basic', from: { key_code: 'c',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+c"                                }] },
  { type: 'basic', from: { key_code: 'd',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+d"                                }] },
  { type: 'basic', from: { key_code: 'e',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+e"                                }] },
  { type: 'basic', from: { key_code: 'f',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f"                                }] },
  { type: 'basic', from: { key_code: 'g',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+g"                                }] },
  { type: 'basic', from: { key_code: 'h',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+h"                                }] },
  { type: 'basic', from: { key_code: 'i',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+i"                                }] },
  { type: 'basic', from: { key_code: 'j',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+j"                                }] },
  { type: 'basic', from: { key_code: 'k',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+k"                                }] },
  { type: 'basic', from: { key_code: 'l',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+l"                                }] },
  { type: 'basic', from: { key_code: 'm',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+m"                                }] },
  { type: 'basic', from: { key_code: 'n',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+n"                                }] },
  { type: 'basic', from: { key_code: 'o',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+o"                                }] },
  { type: 'basic', from: { key_code: 'p',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+p"                                }] },
  { type: 'basic', from: { key_code: 'q',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+q"                                }] },
  { type: 'basic', from: { key_code: 'r',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+r"                                }] },
  { type: 'basic', from: { key_code: 's',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+s"                                }] },
  { type: 'basic', from: { key_code: 't',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+t"                                }] },
  { type: 'basic', from: { key_code: 'u',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+u"                                }] },
  { type: 'basic', from: { key_code: 'v',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+v"                                }] },
  { type: 'basic', from: { key_code: 'w',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+w"                                }] },
  { type: 'basic', from: { key_code: 'x',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+x"                                }] },
  { type: 'basic', from: { key_code: 'y',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+y"                                }] },
  { type: 'basic', from: { key_code: 'z',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+z"                                }] },
  # Number keys
  { type: 'basic', from: { key_code: '0',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+0"                                }] },
  { type: 'basic', from: { key_code: '1',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+1"                                }] },
  { type: 'basic', from: { key_code: '2',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+2"                                }] },
  { type: 'basic', from: { key_code: '3',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+3"                                }] },
  { type: 'basic', from: { key_code: '4',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+4"                                }] },
  { type: 'basic', from: { key_code: '5',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+5"                                }] },
  { type: 'basic', from: { key_code: '6',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+6"                                }] },
  { type: 'basic', from: { key_code: '7',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+7"                                }] },
  { type: 'basic', from: { key_code: '8',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+8"                                }] },
  { type: 'basic', from: { key_code: '9',                      modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+9"                                }] },
  # Function keys
  { type: 'basic', from: { key_code: 'f1',                     modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f1"                               }] },
  { type: 'basic', from: { key_code: 'f2',                     modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f2"                               }] },
  { type: 'basic', from: { key_code: 'f3',                     modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f3"                               }] },
  { type: 'basic', from: { key_code: 'f4',                     modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f4"                               }] },
  { type: 'basic', from: { key_code: 'f5',                     modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f5"                               }] },
  { type: 'basic', from: { key_code: 'f6',                     modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f6"                               }] },
  { type: 'basic', from: { key_code: 'f7',                     modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f7"                               }] },
  { type: 'basic', from: { key_code: 'f8',                     modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f8"                               }] },
  { type: 'basic', from: { key_code: 'f9',                     modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f9"                               }] },
  { type: 'basic', from: { key_code: 'f10',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f10"                              }] },
  { type: 'basic', from: { key_code: 'f11',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f11"                              }] },
  { type: 'basic', from: { key_code: 'f12',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f12"                              }] },
  { type: 'basic', from: { key_code: 'f13',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f13"                              }] },
  { type: 'basic', from: { key_code: 'f14',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f14"                              }] },
  { type: 'basic', from: { key_code: 'f15',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f15"                              }] },
  { type: 'basic', from: { key_code: 'f16',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f16"                              }] },
  { type: 'basic', from: { key_code: 'f17',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f17"                              }] },
  { type: 'basic', from: { key_code: 'f18',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f18"                              }] },
  { type: 'basic', from: { key_code: 'f19',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f19"                              }] },
  { type: 'basic', from: { key_code: 'f20',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f20"                              }] },
  { type: 'basic', from: { key_code: 'f21',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f21"                              }] },
  { type: 'basic', from: { key_code: 'f22',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f22"                              }] },
  { type: 'basic', from: { key_code: 'f23',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f23"                              }] },
  { type: 'basic', from: { key_code: 'f24',                    modifiers: kfm(['right_option', 'shift'], ['caps_lock']) },        to: [{ shell_command: "~/sh/key.sh shift+f24"                              }] },
]

def main
  puts JSON.pretty_generate(
    title: 'Personal rules (@wataash2)',
    rules: [
      {
        description: 'wataash2: misc',
        manipulators: $m + $m_emacs,
      },
    ] # rules
  )
end

main
