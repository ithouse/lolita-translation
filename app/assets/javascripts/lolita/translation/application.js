$(function(){
  $(".tab-language-switch li").on("click",function(){
    $(this).parent().children("li").removeClass("active");
    $(this).addClass("active");
    var locale = $(this).data("locale"),
        tab_name = $(this).data("tab"),
        container = $(this).data("container") || ".tab-content";
    $(container + " .language-wrap").hide(0);
    $("#"+locale+"_for_"+tab_name).show(0);
    resize_all_tinymce_editors();
  });
});