using DocumenterInterLinks
using Documenter
using Documenter: DOCUMENTER_VERSION
using IOCapture: IOCapture
using TestingUtilities: @Test
using Test

include("run_makedocs.jl")


@testset "Instantiate ExternalFallbacks" begin

    captured = IOCapture.capture(rethrow=Union{}) do
        ExternalFallbacks("makedocs" => "@extref Documenter.makedocs",)
    end
    fallbacks = captured.value
    if DOCUMENTER_VERSION >= v"1.3.0-dev"
        @test fallbacks.mapping["makedocs"] == "@extref Documenter.makedocs"
        @Test repr(fallbacks) ==
              "ExternalFallbacks(\"makedocs\" => \"@extref Documenter.makedocs\")"
        @Test repr("text/plain", fallbacks) ==
              "ExternalFallbacks(\"makedocs\" => \"@extref Documenter.makedocs\")"
    else
        @test isempty(fallbacks.mapping)
        @test contains(captured.output, "available only in Documenter ≥ v1.3.0")
        @Test repr(fallbacks) == "ExternalFallbacks()"
    end

    if DOCUMENTER_VERSION >= v"1.3.0-dev"

        captured = IOCapture.capture(rethrow=Union{}) do
            ExternalFallbacks("makedocs" => "Documenter.makedocs",)
        end
        @test captured.value isa ArgumentError
        exception = captured.value
        if exception isa ArgumentError
            @test contains(exception.msg, "value in mapping must start with \"@extref \"")
        end

        @test_throws MethodError begin
            ExternalFallbacks("Documenter.makedocs", "Documenter.deploydocs",)
        end

    end

end


@testset "Fallback Test" begin

    links = InterLinks(
        "Documenter" => (
            "https://documenter.juliadocs.org/stable/",
            joinpath(@__DIR__, "..", "docs", "src", "inventories", "Documenter.toml")
        ),
        "DocInventories" => (
            "https://github.com/JuliaDocs/DocInventories.jl/dev/",
            joinpath(@__DIR__, "..", "docs", "src", "inventories", "DocInventories.toml")
        ),
        "DocumenterInterLinks" => (
            "http://juliadocs.org/DocumenterInterLinks.jl/dev/",
            joinpath(splitext(@__FILE__)[1], "DocumenterInterLinks.toml")
        ),
    )

    captured = IOCapture.capture() do
        ExternalFallbacks(
            "makedocs" => "@extref Documenter.makedocs",
            "Other-Output-Formats" => "@extref Documenter `Other-Output-Formats`",
            "Inventory-File-Formats" => "@extref DocInventories `Inventory-File-Formats`",
            "InterLinks" => "@extref DocumenterInterLinks.InterLinks",
            "Document" => "@extref Documenter.Document",
            "Documenter.getplugin" => "@extref Documenter :jl:method:`Documenter.getplugin-Union{Tuple{T}, Tuple{Documenter.Document, Type{T}}} where T<:Documenter.Plugin`",
        )
    end
    fallbacks = captured.value

    if DOCUMENTER_VERSION >= v"1.3.0-dev"
        @Test repr(fallbacks) ==
              "ExternalFallbacks(\"Documenter.getplugin\" => \"@extref Documenter :jl:method:`Documenter.getplugin-Union{Tuple{T}, Tuple{Documenter.Document, Type{T}}} where T<:Documenter.Plugin`\", \"makedocs\" => \"@extref Documenter.makedocs\", \"Inventory-File-Formats\" => \"@extref DocInventories `Inventory-File-Formats`\", \"Other-Output-Formats\" => \"@extref Documenter `Other-Output-Formats`\", \"InterLinks\" => \"@extref DocumenterInterLinks.InterLinks\", \"Document\" => \"@extref Documenter.Document\")"
        @Test repr("text/plain", fallbacks) ==
              "ExternalFallbacks(\n  \"Documenter.getplugin\" => \"@extref Documenter :jl:method:`Documenter.getplugin-Union{Tuple{T}, Tuple{Documenter.Document, Type{T}}} where T<:Documenter.Plugin`\",\n  \"makedocs\" => \"@extref Documenter.makedocs\",\n  \"Inventory-File-Formats\" => \"@extref DocInventories `Inventory-File-Formats`\",\n  \"Other-Output-Formats\" => \"@extref Documenter `Other-Output-Formats`\",\n  \"InterLinks\" => \"@extref DocumenterInterLinks.InterLinks\",\n  \"Document\" => \"@extref Documenter.Document\",\n)\n"
    end

    Base.eval(Main, quote
        using Documenter
        using DocInventories
        using DocumenterInterLinks
    end)

    run_makedocs(
        splitext(@__FILE__)[1];
        sitename="DocumenterInterLinks.jl",
        plugins=[links, fallbacks],
        format=Documenter.HTML(;
            prettyurls = true,
            canonical  = "https://juliadocs.github.io/DocumenterInterLinks.jl",
            footer     = "Generated by Test",
            edit_link  = "",
            repolink   = "",
        ),
        warnonly=(DOCUMENTER_VERSION < v"1.3.0-dev"),
        check_success=true
    ) do dir, result, success, backtrace, output

        if DOCUMENTER_VERSION >= v"1.3.0-dev"
            @test success
        else
            @test contains(output, "no doc found for reference '[`makedocs`](@ref)'")
            @test contains(
                output,
                "no doc found for reference '[`ExternalFallbacks`](@ref)'"
            )
        end

    end

end


@testset "Fallback Invalid Test" begin

    links = InterLinks(
        "Documenter" => (
            "https://documenter.juliadocs.org/stable/",
            joinpath(@__DIR__, "..", "docs", "src", "inventories", "Documenter.toml")
        ),
        "DocInventories" => (
            "https://github.com/JuliaDocs/DocInventories.jl/dev/",
            joinpath(@__DIR__, "..", "docs", "src", "inventories", "DocInventories.toml")
        ),
        "DocumenterInterLinks" => (
            "http://juliadocs.org/DocumenterInterLinks.jl/dev/",
            joinpath(splitext(@__FILE__)[1], "DocumenterInterLinks.toml")
        ),
    )

    captured = IOCapture.capture() do
        ExternalFallbacks(
            "makedocs" => "@extref UnknownProject Documenter.makedocs",
            "Other-Output-Formats" => "@extref ",
            "Inventory-File-Formats" => "@extref ",
            "InterLinks" => "@extref doc:index",
            "Document" => "@extref Document",
            "Documenter.getplugin" => "@extref ",
        )
    end
    fallbacks = captured.value

    Base.eval(Main, quote
        using Documenter
        using DocInventories
        using DocumenterInterLinks
    end)

    run_makedocs(
        splitext(@__FILE__)[1];
        sitename="DocumenterInterLinks.jl",
        plugins=[links, fallbacks],
        format=Documenter.HTML(;
            prettyurls = true,
            canonical  = "https://juliadocs.github.io/DocumenterInterLinks.jl",
            footer     = "Generated by Test",
            edit_link  = "",
            repolink   = "",
        ),
        check_failure=true
    ) do dir, result, success, backtrace, output

        @test !success
        if DOCUMENTER_VERSION >= v"1.3.0-dev"
            @test contains(output, "Cannot resolve \"@extref Document\"")
            @test contains(output, "is not a complete @extref link")
        end

    end

end
