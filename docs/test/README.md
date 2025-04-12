# Toggle
 ### `<Toggle> Toggle(<table> options)`
 | Option | Description |
 |-|-|
 | Name? | Name of the container holding the toggle. Optional when adding a Toggle to an existing container. (ex. `Colorpicker:Toggle(...)`) |
 | Ref | The reference to the Toggle in the Library table. (ex. usage `Library.Refs[ref].Enabled`) |
 | Default? | Default state of the Toggle. Defaults to `false`. |
 | Callback? | Callback function of the Toggle. Fires each time the state changes, passing `Toggle.Enabled` as the first argument. Defaults to `function() end` |
