###-begin-pnpm-completion-###
Register-ArgumentCompleter -Native -CommandName pnpm,pn -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  $env:SHELL = "pwsh"
  $env:COMP_LINE = $commandAst.ToString()
  $env:COMP_POINT = $cursorPosition
  $elements = @($commandAst.CommandElements | ForEach-Object {
    if ($_ -is [System.Management.Automation.Language.StringConstantExpressionAst]) { $_.Value }
    else { $_.Extent.Text }
  })
  $last = $commandAst.CommandElements[-1]
  if ($last -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $last.Extent.Text -eq $wordToComplete) {
    $wordToComplete = $last.Value
  }
  if ($elements.Count -eq 0 -or $elements[-1] -ne $wordToComplete) {
    $elements += $wordToComplete
  }
  pnpm completion-server -- @elements | Where-Object { $_ } | ForEach-Object {
    $escaped = $_ -replace '\s|#|@|\$|;|,|''|\{|\}|\(|\)|"|`|\||<|>|&','`$&'
    [System.Management.Automation.CompletionResult]::new($escaped, $_, 'ParameterValue', $_)
  }
}
###-end-pnpm-completion-###
