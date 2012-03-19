$(function(){
  $(".tab-language-switch li").live("click",function(){
    $(".tab-language-switch li").removeClass("active")
    $(this).addClass("active");
    var locale = $(this).attr("data-locale")
    var tab_name = $(this).attr("data-tab")
    $(".tab-content .language-wrap").hide(0)
    $("#"+locale+"_attributes_for_"+tab_name).show(0)
    resize_all_tinymce_editors()
  })
})