<?php
class StreamProvider
{
    private string $playerDataUrl;
    private int $streamID;
    private string $streamCategory;

    public function getIDFromURL(string $url): int
    {
        $elements = explode("/", $url);
        return (int) current(explode('-', end($elements)));
    }

    private function sendRequest()
    {
        $response = $this->request(
            method: "POST",
            url: $this->playerDataUrl,
            headers: [
                "x-requested-with: XMLHttpRequest",
                "Cookie: FILMIXNET=ah3mgjr8vgfe84u86vcvu5gcp9"
            ],
            data: http_build_query([
                "post_id" => $this->streamID,
                "showfull" => "true"
            ])
        );

        return json_decode($response, true);
    }

    public function getStreamData(): array
    {
        $stream = [];
        $response = $this->sendRequest();
        if ($response['type'] === 'success') {
            foreach ($response['message']['translations']['video'] as $translation => $video) {
                if ($this->streamCategory === 'film') {
                    $stream[$translation] = $this->convertFromString(
                        explode(',', $this->decode($video))
                    );
                } else {
                    $series = json_decode($this->decode(
                        $this->request("GET", $this->decode($video))
                    ), true);
                    foreach ($series as $serie) {
                        foreach ($serie['folder'] as $folder) {
                            $stream[$translation][trim($serie['title'])][$folder['id']]['title'] = trim($folder['title']);
                            $stream[$translation][trim($serie['title'])][$folder['id']]['quality'] = $this->convertFromString(
                                explode(',', $folder['file'])
                            );
                        }
                    }
                }
            }
        }

        return $stream;
    }

    private function convertFromString(array $list): array
    {
        $quality_list = [];
        foreach ($list as $item) {
            preg_match("/\[(.*?)\]/", $item, $matches);
            if (isset($matches[1])) {
                $quality_list[$matches[1]] = trim(str_replace($matches[0], '', $item));
            }
        }

        return $quality_list;
    }

    public function isMovie(): bool
    {
        return $this->streamCategory === 'film';
    }

    private function decode(string $str) {
        $tokens = [
            ":<:bzl3UHQwaWk0MkdXZVM3TDdB",
            ":<:SURhQnQwOEM5V2Y3bFlyMGVI",
            ":<:bE5qSTlWNVUxZ01uc3h0NFFy",
            ":<:Mm93S0RVb0d6c3VMTkV5aE54",
            ":<:MTluMWlLQnI4OXVic2tTNXpU"
        ];

        $clean = substr($str, 2);
        $clean = str_replace("\\/", "/", $clean);

        while (true) {
            foreach ($tokens as $token) {
                $clean = str_replace($token, "", $clean);
            }
            if (strpos($clean, ":<:") === false) {
                break;
            }
        }

        return base64_decode($clean);
    }

    private function request(string $method, string $url, $headers = [], $data = null): bool|string
    {
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);

        if ($headers !== []) {
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        }

        if ($data !== null) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        }

        $response = curl_exec($ch);

        if ($response === false) {
            throw new Exception("cURL error: " . curl_error($ch));
        }

        curl_close($ch);
        return $response;
    }

    public function __construct(string $url)
    {
        $this->streamID = $this->getIDFromURL($url);
        $uri = parse_url($url);
        $path = explode("/", ltrim($uri["path"], "/"));
        $this->streamCategory = current($path);
        $this->playerDataUrl = sprintf(
            '%s://%s/api/movies/player-data?t=%d',
            $uri['scheme'],
            $uri['host'],
            time()
        );
    }
}

$data = new StreamProvider(url: "https://filmix.my/path/to/video.html")->getStreamData();