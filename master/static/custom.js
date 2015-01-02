$(function(){
    $("pre code").each(function() {
        var $this = $(this),
            $code = $this.html(),
            $unescaped = $("<div/>").html($code).text();
        $this.empty();
        CodeMirror(this, {
            value: $unescaped.trim(),
            mode: "julia",
            readOnly: "nocursor"
        });
    });
});
