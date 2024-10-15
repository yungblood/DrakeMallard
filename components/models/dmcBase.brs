function init()
end function

function onJsonChanged(nodeEvent as object)
    json = nodeEvent.getData()
    onBaseJsonChanged(json)
end function

function onBaseJsonChanged(json as object)
    if json <> invalid then
        m.top.contentId = asString(json.contentId)
        m.top.callToAction = asString(json.callToAction)
        m.top.region = asString(json.currentAvailability?.region)
        m.top.kidsMode = asBoolean(json.currentAvailability?.kidsMode)
        m.top.encodedSeriesId = asString(json.encodedSeriesId)

        image = {}
        for each item in json.image.items()
            if item.value["1.78"] <> invalid
                image[item.key] = asString(item.value["1.78"].items?().peek().value?.default?.url)
            end if
        next
        m.top.image = image

        slug = json.text?.title?.slug?.items?()?.peek?()
        if slug <> invalid
            m.top.slug = asString(slug.value?.default?.content)
        end if

        title = json.text?.title?.full?.items?()?.peek?()
        if title <> invalid
            m.top.title = asString(title.value?.default?.content)
        end if

        ratings = []
        if json.ratings <> invalid and json.ratings.count() > 0
            for each rating in json.ratings
                ratings.push(rating.system + "|" + rating.value)
            next
        end if
        m.top.ratings = ratings

        releases = []
        if json.releases <> invalid and json.releases.count() > 0
            for each release in json.releases
                releases.push(release.date)
            next
        end if
        m.top.releases = releases

        videoArt = []
        for each art in json.videoArt
            if art?.mediaMetadata?.urls <> invalid
                for each media in art.mediaMetadata.urls
                    videoArt.push(media.url)
                next
            end if
        next
        m.top.videoArt = videoArt
    end if
end function
